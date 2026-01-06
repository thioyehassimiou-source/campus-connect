import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppUtils {
  // Format date for display
  static String formatDate(DateTime date, {bool includeTime = false}) {
    if (includeTime) {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Format time for display
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  // Get relative time (e.g., "il y a 2 heures")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'à l\'instant';
    }
  }

  // Validate email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate phone number
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[0-9]{10,15}$').hasMatch(phone);
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Get file icon based on file type
  static IconData getFileIcon(String fileType) {
    if (fileType.startsWith('image/')) return Icons.image;
    if (fileType == 'application/pdf') return Icons.picture_as_pdf;
    if (fileType.contains('document') || fileType.contains('word')) return Icons.description;
    if (fileType.contains('sheet') || fileType.contains('excel')) return Icons.table_chart;
    if (fileType.contains('presentation') || fileType.contains('powerpoint')) return Icons.slideshow;
    if (fileType.contains('audio')) return Icons.audiotrack;
    if (fileType.contains('video')) return Icons.videocam;
    if (fileType.contains('zip') || fileType.contains('rar') || fileType.contains('7z')) return Icons.archive;
    return Icons.insert_drive_file;
  }

  // Get color for grade percentage
  static Color getGradeColor(double percentage) {
    if (percentage >= 80) return const Color(0xFF4CAF50); // Green
    if (percentage >= 60) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFD32F2F); // Red
  }

  // Get color for priority
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return Colors.purple;
      case 'high':
        return const Color(0xFFD32F2F); // Red
      case 'medium':
        return const Color(0xFFFF9800); // Orange
      case 'low':
        return const Color(0xFF4CAF50); // Green
      default:
        return Colors.grey;
    }
  }

  // Show snackbar with error handling
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Show loading dialog
  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Generate random color
  static Color generateRandomColor() {
    return Color((0xFFFFFFFF * (1 + 0.1)).toInt()).withOpacity(1.0);
  }

  // Check if today is the same date
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }

  // Get week number
  static int getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysDifference = date.difference(firstDayOfYear).inDays;
    return ((daysDifference + firstDayOfYear.weekday) / 7).ceil();
  }

  // Validate password strength
  static PasswordStrength validatePassword(String password) {
    if (password.length < 6) return PasswordStrength.weak;
    
    bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    bool hasLower = password.contains(RegExp(r'[a-z]'));
    bool hasNumber = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (hasUpper && hasLower && hasNumber && hasSpecial) {
      return PasswordStrength.strong;
    } else if ((hasUpper && hasLower) || (hasLower && hasNumber) || (hasUpper && hasNumber)) {
      return PasswordStrength.medium;
    } else {
      return PasswordStrength.weak;
    }
  }

  // Get password strength text
  static String getPasswordStrengthText(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Faible';
      case PasswordStrength.medium:
        return 'Moyen';
      case PasswordStrength.strong:
        return 'Fort';
    }
  }

  // Get password strength color
  static Color getPasswordStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }
}

enum PasswordStrength {
  weak,
  medium,
  strong,
}
