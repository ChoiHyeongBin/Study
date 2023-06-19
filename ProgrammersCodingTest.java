package codingTest;

public class ProgrammersCodingTest {

    public static void main(String[] args) {
    	int n = 6;
    	
    	solution(n);
    }
	
    // LV2 멀리 뛰기
    public static long solution(int n) {
    	// 피보나치수열
        long[] dp = new long[n + 2];
        
        dp[0] = 0;
        dp[1] = 1;
        dp[2] = 2;
        
        for (int i = 3; i <= n; i++) {
        	dp[i] = (dp[i - 1] + dp[i - 2]) % 1234567;
        	System.out.println("dp[i]: " + dp[i]);
        }
        
        return dp[n];
    	
    	// 재귀함수
    	/* int answer = 0;

        if (n <= 2) return n;
                answer = (int) (solution(n-1) + solution(n-2));
        System.out.println("answer: " + answer);

        return answer; */
    }

}
