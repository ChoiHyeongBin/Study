package codingTest;

public class ProgrammersCodingTest {

	public static void main(String[] args) {
		int num = 78;
		
		solution(num);
	}

	// 다음 큰 숫자
	public static int solution(int n) {
        int answer = 0;
        // long numCnt = Integer.toBinaryString(n).chars().filter(c -> c == '1').count();	// *시간초과
        int numCnt = Integer.toBinaryString(n).length() - Integer.toBinaryString(n).replace("1", "").length();
        	System.out.println("numCnt : " + numCnt);
        
        while (true) {
//        	System.out.println("현재 n : " + n);
//        	System.out.println("현재 n : " + Integer.toBinaryString(n));
        	n++;
        	
        	// long nextCnt = Integer.toBinaryString(n).chars().filter(c -> c == '1').count();
        	int nextCnt = Integer.toBinaryString(n).length() - Integer.toBinaryString(n).replace("1", "").length();
        	
        	System.out.println("다음 n : " + n);
        	System.out.println("다음 n : " + Integer.toBinaryString(n));
        	System.out.println("nextCnt : " + nextCnt);
        	System.out.println();
        	
        	if (numCnt == nextCnt) {
        		answer = n;
        		break;
        	}
        }
        
        System.out.println("최종 n : " + n);
        return answer;
    }
}
