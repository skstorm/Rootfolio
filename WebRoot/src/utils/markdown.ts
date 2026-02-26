import { marked } from 'marked';

export async function fetchMarkdown(path: string): Promise<string> {
    try {
        const response = await fetch(path);
        if (!response.ok) throw new Error('File not found');
        const text = await response.text();
        return marked(text);
    } catch (error) {
        console.error('Error fetching markdown:', error);
        return '<p class="error">콘텐츠를 불러오는 중 오류가 발생했습니다.</p>';
    }
}

// 초기 목업 데이터 (나중에 파일 시스템 인덱싱으로 교체)
export const contentIndex = {
    studies: [
        { title: 'Rootfolio 프로젝트 시작', date: '2025-02-24', path: '/content/studies/intro.md' },
    ],
    logs: [
        { title: '첫 번째 개발 로그', date: '2025-02-24', path: '/content/logs/log-1.md' },
    ]
};
