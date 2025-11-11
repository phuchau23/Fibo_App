import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swp_app/features/document/domain/entities/document_entities.dart';
import 'package:swp_app/features/document/presentation/blocs/document_providers.dart';

Future<void> showDocumentDetailSheet(
  BuildContext context, {
  required String documentId,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: DocumentDetailSheet(documentId: documentId),
      );
    },
  );
}

class DocumentDetailSheet extends ConsumerWidget {
  final String documentId;
  const DocumentDetailSheet({super.key, required this.documentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(documentDetailProvider(documentId));

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: detailAsync.when(
          data: (detail) => _DetailContent(detail: detail),
          loading: () => const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => SizedBox(
            height: 220,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Không tải được dữ liệu\n$err'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final DocumentDetailEntity detail;
  const _DetailContent({required this.detail});

  @override
  Widget build(BuildContext context) {
    final headerGradient = LinearGradient(
      colors: [const Color(0xFFFFF3E9), const Color(0xFFFFE0CC)],
    );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      maxChildSize: 0.94,
      minChildSize: 0.5,
      builder: (_, controller) {
        return ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: headerGradient,
                border: Border.all(color: Colors.black.withOpacity(.05)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail.summary.title,
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2B2B2B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _Chip(text: 'Version ${detail.summary.version}'),
                      const SizedBox(width: 8),
                      _Chip(text: detail.summary.status),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _InfoSection(
              title: 'Thông tin tài liệu',
              rows: [
                _InfoRow(label: 'Document ID', value: detail.summary.id),
                _InfoRow(
                  label: 'Created at',
                  value: _fmt(detail.summary.createdAt),
                ),
                _InfoRow(label: 'Updated at', value: _fmt(detail.updatedAt)),
                if (detail.extractedTextPath != null)
                  _InfoRow(
                    label: 'Extracted Text Path',
                    value: detail.extractedTextPath!,
                  ),
                if (detail.embeddingStatus != null)
                  _InfoRow(
                    label: 'Embedding Status',
                    value: detail.embeddingStatus!,
                  ),
                if (detail.isEmbedded != null)
                  _InfoRow(
                    label: 'Embedded',
                    value: detail.isEmbedded! ? 'Yes' : 'No',
                  ),
              ],
            ),
            if (detail.topic != null) ...[
              const SizedBox(height: 20),
              _InfoSection(
                title: 'Topic',
                rows: [
                  _InfoRow(label: 'Name', value: detail.topic!.name),
                  if ((detail.topic!.masterTopicId ?? '').isNotEmpty)
                    _InfoRow(
                      label: 'Master Topic ID',
                      value: detail.topic!.masterTopicId!,
                    ),
                  if ((detail.topic!.description ?? '').isNotEmpty)
                    _InfoRow(
                      label: 'Description',
                      value: detail.topic!.description!,
                    ),
                  _InfoRow(label: 'Status', value: detail.topic!.status),
                  _InfoRow(
                    label: 'Created at',
                    value: _fmt(detail.topic!.createdAt),
                  ),
                ],
              ),
            ],
            if (detail.documentType != null) ...[
              const SizedBox(height: 20),
              _InfoSection(
                title: 'Document Type',
                rows: [
                  _InfoRow(label: 'Name', value: detail.documentType!.name),
                  _InfoRow(label: 'Status', value: detail.documentType!.status),
                  _InfoRow(
                    label: 'Created at',
                    value: _fmt(detail.documentType!.createdAt),
                  ),
                ],
              ),
            ],
            if (detail.file != null) ...[
              const SizedBox(height: 20),
              _InfoSection(
                title: 'File',
                rows: [
                  _InfoRow(label: 'Name', value: detail.file!.fileName),
                  if (detail.file!.fileContentType != null)
                    _InfoRow(
                      label: 'Content Type',
                      value: detail.file!.fileContentType!,
                    ),
                  if (detail.file!.fileSize != null)
                    _InfoRow(
                      label: 'Size',
                      value: _formatSize(detail.file!.fileSize!),
                    ),
                  if ((detail.file!.fileUrl ?? '').isNotEmpty)
                    _InfoRow(label: 'File URL', value: detail.file!.fileUrl!),
                  if ((detail.file!.fileKey ?? '').isNotEmpty)
                    _InfoRow(label: 'File Key', value: detail.file!.fileKey!),
                  if (detail.file!.fileBucket != null)
                    _InfoRow(label: 'Bucket', value: detail.file!.fileBucket!),
                  _InfoRow(
                    label: 'Uploaded at',
                    value: _fmt(detail.file!.createdAt),
                  ),
                  _InfoRow(
                    label: 'Last updated',
                    value: _fmt(detail.file!.updatedAt),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  String _fmt(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  String _formatSize(int size) {
    if (size < 1024) return '$size B';
    final kb = size / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<_InfoRow> rows;
  const _InfoSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withOpacity(.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF101828),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFF97316),
        ),
      ),
    );
  }
}
