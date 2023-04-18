package codingTest;

import java.util.Arrays;

public class ProgrammersCodingTest {

	public static void main(String[] args) {
		int a = 3;
		
		solution(a);
	}

	// LV2 피보나치 수 (*못풀어서 구글 참고)
	public static int solution(int n) {
        int answer[] = new int[n + 1];
        System.out.println("answer : " + Arrays.toString(answer));
        
        for (int i = 0; i <= n; i++) {
        	if (i == 0) {
        		answer[i] = 0;
        	} else if (i == 1) {
        		answer[i] = 1;
        	} else {
        		int sum = answer[i - 2] + answer[i - 1];
        		System.out.println("sum : " + sum);
        		answer[i] = sum % 1234567;
        		System.out.println("answer 222 : " + Arrays.toString(answer));
        	}
        }
        
        return answer[n];
    }
}
