import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../screens/auth_screen/login_screen.dart';
import '../services/comments_service.dart';

/// Hisse detay ekranındaki "Yorumlar" sekmesinin içeriği.
///
/// Misafir kullanıcılara giriş yapma çağrısı gösterir.
/// Giriş yapmış kullanıcılara yorum yazma kutusu + canlı yorum listesi sunar.
class StockCommentsTab extends StatefulWidget {
  final String hisseKodu;

  const StockCommentsTab({super.key, required this.hisseKodu});

  @override
  State<StockCommentsTab> createState() => _StockCommentsTabState();
}

class _StockCommentsTabState extends State<StockCommentsTab> {
  final CommentsService _service = CommentsService();
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  // Stream'i bir kez oluşturup sakla; her setState'te yeniden kurulup
  // StreamBuilder'ı "loading" durumuna düşmesin diye.
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _commentsStream =
      _service.watch(widget.hisseKodu);

  // Tema renkleri (company_detail_screen ile aynı tonlar)
  static const Color _primary = Color(0xFF3D8BFF);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    try {
      await _service.add(widget.hisseKodu, text);
      _controller.clear();
      if (!mounted) return;
      FocusScope.of(context).unfocus();
    } on ArgumentError {
      _showSnack('Yorum boş veya çok uzun.');
    } on StateError {
      _showSnack('Yorum yapmak için giriş yapın.');
    } catch (_) {
      _showSnack('Yorum gönderilemedi. Tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _confirmDelete(String commentId) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: const Text('Yorum silinsin mi?'),
        content: const Text('Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _service.delete(widget.hisseKodu, commentId);
    } catch (_) {
      _showSnack('Yorum silinemedi.');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.grey.withValues(alpha: 0.3);

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildGuestPrompt(cardColor, textColor, subTextColor, borderColor);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildComposer(cardColor, textColor, subTextColor, borderColor),
        const SizedBox(height: 16),
        _buildCommentList(
          currentUid: user.uid,
          cardColor: cardColor,
          textColor: textColor,
          subTextColor: subTextColor,
          borderColor: borderColor,
        ),
      ],
    );
  }

  // --- Misafir kullanıcı paneli ---
  Widget _buildGuestPrompt(
    Color cardColor,
    Color textColor,
    Color? subTextColor,
    Color borderColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_outline, size: 40, color: subTextColor),
          const SizedBox(height: 12),
          Text(
            'Yorumları görmek için giriş yapın',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Diğer yatırımcıların ${widget.hisseKodu} hakkındaki '
            'düşüncelerini görmek ve yorum yazmak için hesabınıza girin.',
            style: TextStyle(color: subTextColor, fontSize: 13, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Giriş Yap',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Yorum yazma kutusu ---
  Widget _buildComposer(
    Color cardColor,
    Color textColor,
    Color? subTextColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: _controller,
            maxLines: 4,
            minLines: 2,
            maxLength: CommentsService.maxLength,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: 'Bu hisse hakkındaki düşünceniz...',
              hintStyle: TextStyle(color: subTextColor),
              border: InputBorder.none,
              counterStyle: TextStyle(color: subTextColor, fontSize: 11),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 4),
          ElevatedButton.icon(
            onPressed:
                (_controller.text.trim().isEmpty || _isSending) ? null : _send,
            icon: _isSending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send, size: 16),
            label: const Text('Gönder'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _primary.withValues(alpha: 0.4),
              disabledForegroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Yorum listesi (StreamBuilder) ---
  Widget _buildCommentList({
    required String currentUid,
    required Color cardColor,
    required Color textColor,
    required Color? subTextColor,
    required Color borderColor,
  }) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _commentsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return _buildEmptyOrError(
            icon: Icons.error_outline,
            title: 'Yorumlar yüklenemedi',
            subtitle: 'Bağlantınızı kontrol edip tekrar deneyin.',
            cardColor: cardColor,
            textColor: textColor,
            subTextColor: subTextColor,
            borderColor: borderColor,
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _buildEmptyOrError(
            icon: Icons.forum_outlined,
            title: 'Henüz yorum yok',
            subtitle: 'İlk yorumu sen yaz!',
            cardColor: cardColor,
            textColor: textColor,
            subTextColor: subTextColor,
            borderColor: borderColor,
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data();
            return _buildCommentCard(
              commentId: doc.id,
              data: data,
              isMine: data['uid'] == currentUid,
              cardColor: cardColor,
              textColor: textColor,
              subTextColor: subTextColor,
              borderColor: borderColor,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyOrError({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color cardColor,
    required Color textColor,
    required Color? subTextColor,
    required Color borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: subTextColor, size: 36),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: subTextColor, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard({
    required String commentId,
    required Map<String, dynamic> data,
    required bool isMine,
    required Color cardColor,
    required Color textColor,
    required Color? subTextColor,
    required Color borderColor,
  }) {
    final displayName = (data['displayName'] as String?) ?? 'Anonim';
    final text = (data['text'] as String?) ?? '';
    final createdAt = data['createdAt'];
    final dateLabel = _formatDate(createdAt);
    final initials = _initials(displayName);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _primary.withValues(alpha: 0.15),
            child: Text(
              initials,
              style: const TextStyle(
                color: _primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      dateLabel,
                      style: TextStyle(color: subTextColor, fontSize: 11),
                    ),
                    if (isMine)
                      GestureDetector(
                        onTap: () => _confirmDelete(commentId),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: subTextColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  String _formatDate(dynamic value) {
    if (value is! Timestamp) return 'şimdi';
    final date = value.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'şimdi';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} sa önce';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    return DateFormat('dd.MM.yyyy').format(date);
  }
}
