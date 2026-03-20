import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/result.dart';
import '../../../core/theme/app_colors.dart';
import 'title_provider.dart';

class PromptSandboxPage extends ConsumerStatefulWidget {
  final String? imagePath;
  
  const PromptSandboxPage({super.key, this.imagePath});

  @override
  ConsumerState<PromptSandboxPage> createState() => _PromptSandboxPageState();
}

class _PromptSandboxPageState extends ConsumerState<PromptSandboxPage> {
  late String _selectedStyleId;
  late TextEditingController _tagsController;
  String _resultText = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedStyleId = 'youth';
    _tagsController = TextEditingController(text: "청춘, 학교, 옥상, 노을, 학생");
  }

  @override
  void dispose() {
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _runTest() async {
    if (widget.imagePath == null) return;

    setState(() {
      _isLoading = true;
      _resultText = "생성 중...";
    });

    try {
      final repo = ref.read(titleRepositoryProvider);
      final result = await repo.generateTitleFromImage(
        image: File(widget.imagePath!),
        styleId: _selectedStyleId,
      );

      switch (result) {
        case Success(data: final data):
          setState(() {
            _resultText = data.text;
            _isLoading = false;
          });
        case Failure(failure: final failure):
          setState(() {
            _resultText = "실패: $failure";
            _isLoading = false;
          });
      }
    } catch (e) {
      setState(() {
        _resultText = "에러: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final promptService = ref.watch(promptTemplateServiceProvider);
    final selectedStyleId = promptService.availableStyleIds.contains(_selectedStyleId)
        ? _selectedStyleId
        : promptService.availableStyleIds.first;
    final fullPrompt = promptService.generatePrompt(selectedStyleId, _tagsController.text);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Prompt Sandbox (Debug)'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 이미지 미리보기
            if (widget.imagePath != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(File(widget.imagePath!)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // 2. 스타일 선택
            const Text('장르 선택', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedStyleId,
              isExpanded: true,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              items: promptService.availableStyleIds.map((id) {
                return DropdownMenuItem(value: id, child: Text(id));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedStyleId = val);
              },
            ),
            const SizedBox(height: 20),

            // 3. 분석 태그 모킹
            const Text('이미지 분석 태그 (Mock)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _tagsController,
              style: const TextStyle(color: Colors.white70),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),

            // 4. 최종 조합 프롬프트 확인
            const Text('최종 조합 프롬프트 (Read-only)', style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
              child: Text(fullPrompt, style: const TextStyle(color: Colors.white60, fontSize: 12)),
            ),
            const SizedBox(height: 30),

            // 5. 실행 및 결과
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _runTest,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.black) 
                    : const Text('테스트 실행 (Gemini API 호출)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            
            if (_resultText.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(0.1),
                  border: Border.all(color: Colors.yellow),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text('생성된 자막', style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(_resultText, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
