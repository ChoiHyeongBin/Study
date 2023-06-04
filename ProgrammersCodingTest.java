package codingTest;

import java.util.Arrays;
import java.util.Comparator;
import java.util.LinkedList;

public class ProgrammersCodingTest {

    public static void main(String[] args) {
    	int k = 3;
    	int m = 4;
//    	int[] score = new int[] {4, 1, 2, 2, 4, 4, 4, 4, 1, 2, 4, 2};
    	int[] score = new int[] {1, 2, 3, 1, 2, 3, 1};
    	
    	solution(k, m, score);
    }
	
    // LV1 과일 장수
    public static int solution(int k, int m, int[] score) {
        int answer = 0;
        Integer[] tmp = Arrays.stream(score).boxed().toArray(Integer[]::new);
        Arrays.sort(tmp, Comparator.reverseOrder());
        
        System.out.println(Arrays.toString(tmp));

        // *시간 초과
//        LinkedList<Integer> newArr = new LinkedList<Integer>();
        
//        for (Integer i : tmp) {
//        	newArr.add(i);
//        }
        
//        System.out.println(newArr);
        
        int cnt = 0;
        for (int i = 0; i < tmp.length; i++) {
        	cnt++;
        	
        	if (cnt == m) {
        		answer += tmp[i] * m;
        		cnt = 0;
        	}
        }
        
        System.out.println("answer: " + answer);
        return answer;
    }

}
