package codingTest;

public class ProgrammersCodingTest {

	public static void main(String[] args) {
		int num = 15;
		
		solution(num);
	}

	// 숫자의 표현 (*못풀어서 해설 참조)
	static int allCnt = 0;
	public static int solution(int n) {
        int answer = 0;

        for (int i = 1; i <= n; i++) {
        	int sum = 0;
        	
        	for (int j = i; j <= n; j++) {
        		System.out.println(j);
        		sum += j;
        		
        		if (sum == n) {
        			answer++;
        			break;
        		} else if (sum > n) {
        			break;
        		}
        	}
        	System.out.println("sum : " + sum);
        	System.out.println();
        }
        
        System.out.println("answer : " + answer);
        return answer;
    }
}
