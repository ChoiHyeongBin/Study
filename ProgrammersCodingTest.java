package codingTest;

import java.util.Arrays;

public class ProgrammersCodingTest {

	public static void main(String[] args) {
		String str = "foobar";
		
		solution(str);
	}

	// 가장 가까운 같은 글자
	public static int[] solution(String s) {
        int[] answer = new int[s.length()];
        String[] arrStr = s.split("");
        
        for (int i = 0; i < arrStr.length; i++) {
        	System.out.println(i);
        	System.out.println(arrStr[i]);
        	
        	int idx = s.indexOf(arrStr[i]);
        	int cnt = 0;
        	while (idx != -1) {
        		System.out.println("idx : " + idx);
        		System.out.println("cnt : " + cnt);
        		cnt = idx;
        		idx = s.indexOf(arrStr[i], idx + 1);

        		if (idx == i) {
        			System.out.println("들어옴");
        			answer[i] = idx - cnt;
        			break;
        		} else {
        			answer[i] = -1;
        		}
        		
//        		cnt++;
        	}
        	System.out.println();
        }
        
        System.out.println("answer : " + Arrays.toString(answer));
        return answer;
    }
}
