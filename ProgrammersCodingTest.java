package codingTest;

import java.util.HashSet;
import java.util.Set;

public class ProgrammersCodingTest {

	public static void main(String[] args) {
		int[] arrNum = new int[] {3,3,3,2,2,4, 5, 6};
		
		solution(arrNum);
	}

	// LV1 폰켓몬
	public static int solution(int[] nums) {
        int answer = 0;
        Set<Integer> set = new HashSet<Integer>();
        int outCnt = nums.length / 2;
        System.out.println("outCnt : " + outCnt);
        
        for (int i = 0; i < nums.length; i++) {
        	set.add(nums[i]);
        }
        
        System.out.println("set : " + set);
        System.out.println("set.size() : " + set.size());
        
        if (set.size() > outCnt) {
        	answer = outCnt;
        } else {
        	answer = set.size();
        }
        
        System.out.println("answer : " + answer);
        return answer;
    }
}
