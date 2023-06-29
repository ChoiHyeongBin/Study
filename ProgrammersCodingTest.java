package codingTest;

import java.util.Arrays;

public class ProgrammersCodingTest {

    public static void main(String[] args) {
//    	int[][] arr1 = {{2, 3, 2}, {4, 2, 4}, {3, 1, 4}};
    	int[][] arr1 = {{1, 4}, {3, 2}, {4, 1}};
//    	int[][] arr2 = {{5, 4, 3}, {2, 4, 1}, {3, 1, 1}};
    	int[][] arr2 = {{3, 3}, {3, 3}};
    	
    	solution(arr1, arr2);
    }
	
    // LV2 행렬의 곱셈
    public static int[][] solution(int[][] arr1, int[][] arr2) {
        int[][] answer = new int[arr1.length][arr2[0].length];
//        System.out.println(Arrays.deepToString(answer));
        
        for (int i = 0; i < arr1.length; ++i) {
        	System.out.println(Arrays.toString(arr1[i]));
        	
        	for (int j = 0; j < arr2[0].length; ++j) {
        		for (int k = 0; k < arr1[0].length; ++k) {
        			System.out.println(arr1[i][k]);
        			System.out.println(arr2[k][j]);
        			System.out.println();
        			
        			answer[i][j] += arr1[i][k] * arr2[k][j];
        		}
        	}
        }
        
        /* 실패
        int cnt = 0;	// 배열 전체 개수
        
        for (int i = 0; i < arr1.length; i++) {
        	System.out.println(Arrays.toString(arr1[i]));

        	cnt += arr1[i].length;
        }
        
        System.out.println("cnt: " + cnt);
        
        for (int i = 0; i < arr1.length; i++) {
        	System.out.println(Arrays.toString(arr1[i]));
        	
        	for (int j = 0; j < cnt; j++) {
        		int n = 0;
        		
        		for (int k = 0; k < arr1[i].length; k++) {
            		System.out.println(arr1[i][n] * arr2[k][i]);
            		n++;
            		
            		if (n >= arr1[i].length) {
            			n = 0;
            		}
                }
        	}
        	
        	System.out.println();
        }
         */
        
        System.out.println(Arrays.deepToString(answer));
        return answer;
    }
	
}
