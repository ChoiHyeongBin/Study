package codingTest;

import java.util.Arrays;

public class ProgrammersCodingTest {

	public static void main(String[] args) {
		int brown = 10;
		int yellow = 2;
		
		solution(brown, yellow);
	}

	// LV2 카펫
	public static int[] solution(int brown, int yellow) {
        int[] answer = new int[2];
        int sum = brown + yellow;	// 격자 총갯수
        
        for (int i = 3; i < sum; i++) {
        	int j = sum / i;
//        	System.out.println("j : " + j);
        	
        	if (sum % i == 0 && j >= 3) {
        		int col = Math.max(i, j);
        		int row = Math.min(i, j);
        		System.out.println("col: " + col + ", row: " + row);
        		int center = (col - 2) * (row - 2);
        		System.out.println("center: " + center);
        		
        		if (center == yellow) {
        			answer[0] = col;
        			answer[1] = row;
        		}
        	}
        }
        
        System.out.println(Arrays.toString(answer));
        return answer;
    }
}
