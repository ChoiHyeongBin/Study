package codingTest;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class ProgrammersCodingTest {

	public static void main(String[] args) {
		int num = 2;
		String[] arrStr = new String[] {"hello", "one", "even", "never", "now", "world", "draw"};
		
		solution(num, arrStr);
	}

	// LV2 영어 끝말잇기
	public static int[] solution(int n, String[] words) {
		int[] answer = new int[2];
		List<String> list = new ArrayList<String>();
		boolean flag = true;
		
		for (int i = 0; i < words.length; i++) {
			System.out.println("words: " + words[i]);
			
			if (i > 0 && words[i - 1].charAt(words[i - 1].length() - 1) != words[i].charAt(0)
				|| list.contains(words[i])) {	// 이전에 등장한 단어
				answer[0] = (i % n) + 1;	// 사람 번호
				answer[1] = (i / n) + 1;	// 차례
				flag = false;
				break;
			}
			
			list.add(words[i]);
		}
		
		if (flag)	answer = new int[] {0, 0};
		System.out.println("answer: " + Arrays.toString(answer));
		return answer;
		
        /* int[] answer = {};

        int cnt = 0;
        for (int i = 0; i < words.length; i++) {
        	if (i + 1 == words.length) {
        		i = 0;
        	}
        	
        	System.out.println("words 마지막글자: " + words[i].substring(words[i].length() - 1));
        	System.out.println("words 첫번째글자: " + words[i + 1].substring(0, 1));
        	System.out.println("words : " + words[i]);
        	
        	if (!words[i].substring(words[i].length() - 1).equals(words[i + 1].substring(0, 1))) {
        		break;
        	}
        	
        	if () {
        		
        	}
        }

        return answer; */
    }
}
