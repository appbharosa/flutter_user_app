import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../free_lab_report_bloc/free_lab_report_bloc.dart';
import '../free_lab_report_bloc/free_lab_report_event.dart';
import '../free_lab_report_bloc/free_lab_report_state.dart';
import 'package:path_provider/path_provider.dart';

class FreeLabReportsScreen extends StatelessWidget {
  const FreeLabReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<FreeLabReportBloc>()..add(LoadFreeLabReports()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Free Lab Reports', style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: AppColors.whiteColor,
          ),),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<FreeLabReportBloc, FreeLabReportState>(
          builder: (context, state) {
            if (state is FreeLabReportLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FreeLabReportLoaded) {
              final reports = state.reports;
              if (reports.isEmpty) {
                return const Center(child: Text('No reports found.'));
              }
              return ListView.builder(
                itemCount: reports.length,
                itemBuilder: (ctx, index) {
                  final report = reports[index];
                  final isPdf = report.imageUrl.toLowerCase().endsWith('.pdf');
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Icon(
                        isPdf ? Icons.picture_as_pdf : Icons.image,
                        color: isPdf ? Colors.red : AppColors.blue,
                      ),
                      title: Text(
                        report.type.isNotEmpty ? report.type : 'Report #${report.id}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(report.imageUrl),
                      trailing: const Icon(Icons.visibility),
                      onTap: () => _previewReport(context, report.imageUrl, isPdf),
                    ),
                  );
                },
              );
            } else if (state is FreeLabReportError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  void _previewReport(BuildContext context, String url, bool isPdf) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid report URL'), backgroundColor: Colors.red),
      );
      return;
    }

    if (isPdf) {
      // Show loading indicator while downloading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Download PDF to temporary directory
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf');
        final response = await Dio().download(url, file.path);
        if (response.statusCode == 200) {
          // Close loading dialog
          if (context.mounted) Navigator.pop(context);
          // Open PDF viewer
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(
                    title: const Text('PDF Report', style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: AppColors.whiteColor,
                    ),),
                    backgroundColor: AppColors.blue,
                    foregroundColor: Colors.white,
                  ),
                  body: PDFView(
                    filePath: file.path,
                    enableSwipe: true,
                    swipeHorizontal: false,
                    autoSpacing: false,
                    pageFling: true,
                    onError: (error) {
                      debugPrint('PDF Error: $error');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to load PDF'), backgroundColor: Colors.red),
                        );
                      }
                    },
                  ),
                ),
              ),
            );
          }
        } else {
          if (context.mounted) Navigator.pop(context);
          throw Exception('Download failed');
        }
      } catch (e) {
        if (context.mounted) Navigator.pop(context);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to download PDF'), backgroundColor: Colors.red),
          );
        }
      }
    } else {
      // Image preview with interactive viewer
      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: CachedNetworkImage(
                    imageUrl: url,
                    placeholder: (_, __) => const CircularProgressIndicator(),
                    errorWidget: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.close, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}