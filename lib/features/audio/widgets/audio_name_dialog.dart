import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:app/l10n/app_localizations.dart';
import 'package:app/theme/app_theme.dart';

/// 通用的音频名称输入对话框
/// 
/// 用于设置或重命名音频文件名称
class AudioNameDialog extends StatefulWidget {
  /// 对话框标题
  final String title;
  
  /// 提示文本
  final String? hint;
  
  /// 默认名称（不含扩展名）
  final String defaultName;
  
  /// 文件扩展名（可选，如果提供则显示在输入框右侧）
  final String? extension;
  
  /// 最大长度限制
  final int maxLength;

  const AudioNameDialog({
    super.key,
    required this.title,
    this.hint,
    required this.defaultName,
    this.extension,
    this.maxLength = 30,
  });

  /// 显示对话框并返回用户输入的名称
  /// 
  /// 返回 null 表示用户取消，返回非空字符串表示用户确认的名称
  static Future<String?> show(
    BuildContext context, {
    required String title,
    String? hint,
    required String defaultName,
    String? extension,
    int maxLength = 30,
  }) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AudioNameDialog(
        title: title,
        hint: hint,
        defaultName: defaultName,
        extension: extension,
        maxLength: maxLength,
      ),
    );
  }

  @override
  State<AudioNameDialog> createState() => _AudioNameDialogState();
}

class _AudioNameDialogState extends State<AudioNameDialog> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    // 确保 defaultName 不包含扩展名
    String nameWithoutExtension = widget.defaultName;
    if (widget.extension != null && widget.extension!.isNotEmpty) {
      // 如果提供了扩展名，确保 defaultName 不包含它
      if (nameWithoutExtension.endsWith(widget.extension!)) {
        nameWithoutExtension = nameWithoutExtension.substring(
          0,
          nameWithoutExtension.length - widget.extension!.length,
        );
      }
      // 也尝试使用 path 库的方法去除扩展名（以防万一）
      final ext = p.extension(nameWithoutExtension);
      if (ext.isNotEmpty) {
        nameWithoutExtension = p.basenameWithoutExtension(nameWithoutExtension);
      }
    } else {
      // 如果没有提供扩展名，但 defaultName 可能包含扩展名，尝试去除
      final ext = p.extension(nameWithoutExtension);
      if (ext.isNotEmpty) {
        nameWithoutExtension = p.basenameWithoutExtension(nameWithoutExtension);
      }
    }
    _nameController = TextEditingController(text: nameWithoutExtension);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      Navigator.of(context).pop(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    // 对话框宽度：屏幕宽度的 90%，最小 400，最大 700
    final dialogWidth = (screenWidth * 0.9).clamp(400.0, 700.0);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: LinuSpacing.lg),
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.all(LinuSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              widget.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            if (widget.hint != null) ...[
              const SizedBox(height: LinuSpacing.md),
              Text(
                widget.hint!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            
            const SizedBox(height: LinuSpacing.xl),
            
            // 输入框（不显示扩展名）
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.audioName,
                hintText: l10n.enterAudioName,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: LinuSpacing.md,
                  vertical: LinuSpacing.md,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(LinuSpacing.sm),
                ),
              ),
              maxLength: widget.maxLength,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleConfirm(),
            ),
            
            const SizedBox(height: LinuSpacing.xl),
            
            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: LinuSpacing.lg,
                      vertical: LinuSpacing.md,
                    ),
                  ),
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: LinuSpacing.md),
                FilledButton(
                  onPressed: _handleConfirm,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: LinuSpacing.lg,
                      vertical: LinuSpacing.md,
                    ),
                  ),
                  child: Text(l10n.confirm),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
