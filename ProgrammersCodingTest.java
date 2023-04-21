package codingTest;

import java.util.Stack;

public class ProgrammersCodingTest {

	public static void main(String[] args) {
		String str = "cdcd";
		
		solution(str);
	}

	// LV2 짝지어 제거하기 (*기존코드는 테스트케이스 2~8까지 시간초과)
	public static int solution(String s) {
		Stack<Character> stack = new Stack<>();
		
		for (char ch : s.toCharArray()) {
			System.out.println("ch : " + ch);
			
			if (!stack.isEmpty() && stack.peek() == ch) {
				stack.pop();
			} else {
				stack.push(ch);
			}
		}
		
		return stack.isEmpty() ? 1 : 0;
	}

	/* static int answer = -1;
	public static int solution(String s) {
        strProc(s);
        
        System.out.println("answer : " + answer);
        return answer;
    }
	
	public static void strProc(String s) {
		int result = 0;
		String[] arrStr = s.split("");
		StringBuffer sb = new StringBuffer();
        sb.append(s);
        System.out.println("sb : " + sb);
        
        int eqCnt = 0;
		for (int i = 0; i < arrStr.length - 1; i++) {
        	if (arrStr[i].equals(arrStr[i + 1])) {
        		sb.deleteCharAt(i);
        		sb.deleteCharAt(i);
        		eqCnt++;
        		
        		break;
        	}
        	
        	System.out.println("중간 sb : " + sb);
        }
        System.out.println("최종 sb : " + sb);
        System.out.println("최종 sb.length() : " + sb.length());
        System.out.println();
        
		if (sb.length() == 0) {
			answer = 1;
        } else if (eqCnt == 0) {
        	answer = 0;
        } else {
        	strProc(sb.toString());
        }
		
		System.out.println("result : " + result);
	} */
}
