import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/inspection.dart';
import '../providers/inspection_provider.dart';
import '../screens/add_inspection.dart';
import 'inspection_dialog.dart';

class InspectionTile extends StatelessWidget {
  final Inspection inspection;

  const InspectionTile({super.key, required this.inspection});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final darkGreen = const Color(0xFF1B5E20);
    final midGreen = const Color(0xFF4CAF50);

    // Format date
    final date = DateTime.parse(inspection.dateCreated);
    final formattedDate =
        "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => InspectionDetailDialog(inspection: inspection),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: darkGreen.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Thumbnail image
            SizedBox(
              width: screenWidth * 0.25,
              height: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: inspection.photos.isNotEmpty
                    ? Image.file(
                        File(inspection.photos.first),
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 40),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    inspection.propertyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: darkGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: _getRatingColor(inspection.rating),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        inspection.rating,
                        style: TextStyle(
                          fontSize: 14,
                          color: _getRatingColor(inspection.rating),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: midGreen,
                    ),
                  ),
                ],
              ),
            ),
            // Action buttons
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    size: 28,
                    color: midGreen,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddInspectionScreen(
                          existingInspection: inspection,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    size: 28,
                    color: Colors.red,
                  ),
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(String rating) {
    switch (rating) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.blue;
      case 'Fair':
        return Colors.orange;
      case 'Poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Inspection"),
        content: const Text(
          "Are you sure you want to delete this inspection?\nThis action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<InspectionProvider>().deleteInspection(inspection.id!);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Inspection deleted successfully"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}