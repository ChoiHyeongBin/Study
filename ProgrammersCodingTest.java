package codingTest;

import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

public class ProgrammersCodingTest {

	public static void main(String[] args) {
		int k = 4;
		int[] score = new int[] {0, 300, 40, 300, 20, 70, 150, 50, 500, 1000};
		
		solution(k, score);
	}

	// LV1 명예의 전당 (1)
	public static int[] solution(int k, int[] score) {
        int[] answer = new int[score.length];
        List<Integer> scoreList = new LinkedList<Integer>();
        
        for (int i = 0; i < score.length; i++) {
        	scoreList.add(score[i]);
        	Collections.sort(scoreList, Collections.reverseOrder());
        	System.out.println(scoreList);
        	
        	// 4일차부터 처리
        	if (i >= k) {
        		answer[i] = scoreList.get(k - 1);
			} else { 
				answer[i] = scoreList.get(scoreList.size() - 1);
			}
				 
        }
        
        System.out.println("answer: " + Arrays.toString(answer));
        return answer;
		
		// *PriorityQueue를 사용한 방법
		/* int[] answer = new int[score.length];

        PriorityQueue<Integer> priorityQueue = new PriorityQueue<>();

        int temp = 0;

        for(int i = 0; i < score.length; i++) {

            priorityQueue.add(score[i]);
            System.out.println("priorityQueue: " + priorityQueue);
            if (priorityQueue.size() > k) {
            	System.out.println("탔음, 인덱스 " + i);
                priorityQueue.poll();
            }

            answer[i] = priorityQueue.peek();
        }


        System.out.println("answer: " + Arrays.toString(answer));
        return answer; */
    }

}
