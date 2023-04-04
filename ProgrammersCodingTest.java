package codingTest;

import java.util.Arrays;

public class ProgrammersCodingTest {

	public static void main(String[] args) {
		String str = "1111111";
		
		solution(str);
	}

	// 이진 변환 반복하기
//	static int lastDelCnt = 0;
//	static int chgCnt 	  = 0;	// 이진 변환 회차
	static int[] answer = new int[2];
	public static int[] solution(String s) {
		System.out.println("answer : " + Arrays.toString(answer));
		int lastDelCnt = 0;
		int chgCnt 	   = 0;	// 이진 변환 회차
		
		if (!"1".equals(s)) {
			removeProc(s, lastDelCnt, chgCnt);
		}

		return answer;
    }

	public static void removeProc(String s, int lastDelCnt, int chgCnt) {
		String[] arrStr = s.split("");
        
        String newStr = "";
        int delCnt = 0;		// 	제거할 0의 개수
        int newLen = 0;
        for (int i = 0; i < arrStr.length; i++) {
//        	System.out.println("arrStr[i] : " + arrStr[i]);
        	
        	if (!"0".equals(arrStr[i])) {
        		newStr += arrStr[i];
        	} else {
        		delCnt += 1;
        	}
        }
        
        chgCnt += 1;
        newLen += newStr.length();
        
        System.out.println("delCnt : " + delCnt);
        System.out.println("newLen : " + newLen);
        System.out.println("newStr : " + newStr);
        System.out.println("이진 변환 결과 : " + Integer.toBinaryString(newLen));
        
        lastDelCnt += delCnt;
        
        System.out.println("lastDelCnt : " + lastDelCnt);
        System.out.println("chgCnt : " + chgCnt);
        System.out.println();
        
        if (!"1".equals(Integer.toBinaryString(newLen))) {
        	removeProc(Integer.toBinaryString(newLen), lastDelCnt, chgCnt);
        } else {
        	answer[0] = chgCnt;
        	answer[1] = lastDelCnt;
        	
        	solution(Integer.toBinaryString(newLen));
        }
	}
	
}
