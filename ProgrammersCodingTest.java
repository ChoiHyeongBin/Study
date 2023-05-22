package codingTest;

public class ProgrammersCodingTest {

    public static void main(String[] args) {
    	int n = 10;
    	
    	solution(n);
    }
	
    // LV1 소수 찾기
    public static int solution(int n) {
        int answer = 0;
        
        for (int i = 2; i <= n; i++) {
        	System.out.println("i: " + i);
        	boolean flag = true;
        	
        	for (int j = 2; j <= Math.sqrt(i); j++) {
        		System.out.println("j: " + j);
        		
        		// 나누어 떨어지면 소수 X
        		if (i % j == 0) {
        			flag = false;
        			break;
        		}
        	}
        	System.out.println();
        	
        	if (flag)	answer++;
        }
        
        System.out.println("answer: " + answer);
        return answer;
    }

}
