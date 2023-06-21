package codingTest;

import java.util.Stack;

public class ProgrammersCodingTest {

    public static void main(String[] args) {
//    	String str = "[](){}";
    	String str = "}]()[{";
    	
    	solution(str);
    }
	
    // LV2 괄호 회전하기
    public static int solution(String s) {
        int answer = 0;
//        String temp = "";
        
        for (int i = 0; i < s.length(); i++) {
        	System.out.println(s);
        	
        	System.out.println(check(s));;
        	
        	if (check(s))	answer++;
        	
//        	System.out.println(s.matches("[\\[\\]]"));
        	
        	/*String fileName = "[ㄴ]";
        	boolean result = fileName.matches("[\\[\\]]*");
        	System.out.println(result);*/
        	
        	/*Pattern pattern = Pattern.compile(".*" + "[]" + ".*");
        	Matcher matcher = pattern.matcher(s);
        	System.out.println(matcher);*/
        	
        	s = s.substring(1, s.length()) + s.charAt(0);
        }
        
        System.out.println("answer: " + answer);
        return answer;
    }

    public static boolean check(String input) {
		Stack<Character> stack = new Stack<>();
		for (int i=0; i<input.length(); i++) {
			if (isOpen(input.charAt(i))) {
				stack.push(input.charAt(i));
			} else {
				// isClose()에 가장 상단의 값 가져가고, 맞으면 가장 최근꺼 삭제
				if (!stack.empty() && isClose(input.charAt(i), stack.peek())) stack.pop();
				else return false;
			}
		}
		// 스택에 데이터가 있으면 괄호 쌍이 아니라는 뜻임
		if (stack.empty()) return true;
		return false;
	}
    
    public static boolean isOpen(char input) {
		if (input == '{' || input == '[' || input == '(') return true;
		else return false;
	}
	
	public static boolean isClose(char input, char top) {
		if (input == '}' && top == '{') return true;
		else if (input == ']' && top == '[') return true;
		else if (input == ')' && top == '(') return true;
		else return false;
	}
	
}
