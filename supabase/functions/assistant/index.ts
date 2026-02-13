import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const groqKey = Deno.env.get('GROQ_API_KEY')
    if (!groqKey) {
      throw new Error('Erreur de configuration serveur (GROQ_API_KEY manquante)')
    }

    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Non autorisé: Token manquant' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    )

    const { data: { user }, error: userError } = await supabaseClient.auth.getUser()
    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: 'Interdit: Validation utilisateur échouée' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const { message } = await req.json()
    if (!message) {
      return new Response(JSON.stringify({ error: 'Message requis' }), { status: 400, headers: corsHeaders })
    }

    // --- CONTEXTE UTILISATEUR ---
    const { data: profile } = await supabaseClient
      .from('profiles')
      .select('*, faculties(nom), departments(nom)')
      .eq('id', user.id)
      .maybeSingle();

    const metadata = user.user_metadata || {};
    const fullName = profile?.nom || profile?.full_name || metadata.nom || metadata.full_name || (metadata.first_name ? `${metadata.first_name} ${metadata.last_name || ''}` : 'Utilisateur');

    const identityContext = `IDENTITÉ UTILISATEUR :
    - Nom Complet : ${fullName}
    - Rôle : ${profile?.role || metadata.role || 'Étudiant'}
    - Faculté : ${profile?.faculties?.nom || metadata.faculty_name || 'Non renseignée'}
    - Département : ${profile?.departments?.nom || metadata.department_name || 'Non renseigné'}
    - Niveau : ${profile?.niveau || metadata.niveau || 'Non renseigné'}
    - ID Utilisateur : ${user.id}`;

    const tools = [
      {
        type: "function",
        function: {
          name: "get_schedule",
          description: "Récupérer l'emploi du temps de l'utilisateur",
          parameters: {
            type: "object",
            properties: {
              niveau: { type: "string" },
              day: { type: "integer", description: "0=Lundi, 6=Dimanche" }
            },
          },
        },
      },
      {
        type: "function",
        function: {
          name: "add_schedule_item",
          description: "Ajouter un cours (Enseignants seulement)",
          parameters: {
            type: "object",
            properties: {
              subject: { type: "string" },
              startTime: { type: "string" },
              endTime: { type: "string" },
              room: { type: "string" },
              niveau: { type: "string" },
              type: { type: "string", enum: ["CM", "TD", "TP"] }
            },
            required: ["subject", "startTime", "endTime", "room", "niveau"]
          },
        },
      },
      {
        type: "function",
        function: {
          name: "post_announcement",
          description: "Publier une annonce",
          parameters: {
            type: "object",
            properties: {
              title: { type: "string" },
              content: { type: "string" },
              category: { type: "string", enum: ["Academic", "Event", "Administrative", "Urgent"] }
            },
            required: ["title", "content", "category"]
          },
        },
      },
      {
        type: "function",
        function: {
          name: "get_announcements",
          description: "Lire les annonces",
          parameters: {
            type: "object",
            properties: { limit: { type: "integer", default: 5 } },
          },
        }
      }
    ];

    const systemPrompt = `Tu es l'Assistant CampusConnect pour l'Université de Labé (Campus de Hafia).
    
    ${identityContext}

    RÈGLES :
    1. Utilise TOUJOURS le nom complet de l'utilisateur (${fullName}) pour être chaleureux.
    2. Ne dis JAMAIS que tu n'as pas accès à son nom.
    3. Réponds TOUJOURS au format JSON : { "reply": "ton message" }.
    4. Utilise les outils pour l'emploi du temps ou les annonces.
    5. Parle en français.`;

    let messages = [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: message }
    ];

    const callGroq = async (msgs: any) => {
      const resp = await fetch('https://api.groq.com/openai/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${groqKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: 'llama-3.3-70b-versatile',
          messages: msgs,
          tools: tools,
          tool_choice: "auto",
          response_format: { type: "json_object" }
        }),
      });
      return await resp.json();
    };

    let groqData = await callGroq(messages);
    let choice = groqData.choices?.[0];

    if (choice?.message?.tool_calls) {
      messages.push(choice.message);
      for (const toolCall of choice.message.tool_calls) {
        const name = toolCall.function.name;
        const args = JSON.parse(toolCall.function.arguments);
        let content = "";

        if (name === "get_schedule") {
          const { data } = await supabaseClient.from('schedules').select('*').eq('niveau', args.niveau || profile?.niveau || '');
          content = JSON.stringify(data || []);
        } else if (name === "get_announcements") {
          const { data } = await supabaseClient.from('announcements').select('*').order('created_at', { ascending: false }).limit(args.limit || 5);
          content = JSON.stringify(data || []);
        } else if (name === "post_announcement") {
          const { error } = await supabaseClient.from('announcements').insert({ ...args, author_id: user.id });
          content = error ? `Erreur: ${error.message}` : "Annonce publiée.";
        } else if (name === "add_schedule_item") {
          if (profile?.role === 'Enseignant') {
            const { error } = await supabaseClient.from('schedules').insert({ ...args, teacher: fullName });
            content = error ? `Erreur: ${error.message}` : "Cours ajouté.";
          } else {
            content = "Erreur: Réservé aux enseignants.";
          }
        }

        messages.push({ tool_call_id: toolCall.id, role: "tool", name, content });
      }
      groqData = await callGroq(messages);
      choice = groqData.choices?.[0];
    }

    const reply = JSON.parse(choice?.message?.content || '{"reply": "Erreur de réponse"}').reply;

    return new Response(JSON.stringify({ reply }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });

  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500, headers: corsHeaders });
  }
})
