package codingTest;

public class ProgrammersCodingTest {

    public static void main(String[] args) {
    	int n = 5000;
    	
    	solution(n);
    }
	
    // LV2 점프와 순간 이동
    public static int solution(int n) {
        int ans = 0;

        while (n != 0) {
        		System.out.println(n);
        	if (n % 2 == 0) {	// 2
        		n /= 2;
        	} else {	// 2
        		n -= 1;
        		// n--;
        		ans++;
        	}
        }

        System.out.println("ans: " + ans);
        return ans;
    }

}
