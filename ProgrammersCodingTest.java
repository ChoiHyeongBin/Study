package codingTest;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

public class ProgrammersCodingTest {

	public static void main(String[] args) {
		int[] people = new int[] {50, 30, 20, 70, 10};
//		int[] people = new int[] {70, 80, 50};
//		int[] people = new int[] {70, 50, 40, 50};
		int limit = 100;
		
		solution(people, limit);
	}

	// LV2 구명보트
	public static int solution(int[] people, int limit) {
		int answer = 0;
		
		Arrays.sort(people);
		System.out.println("people: " + Arrays.toString(people));
		
		int min = 0;
		for (int max = people.length - 1; min <= max; max--) {
			System.out.println("max: " + max);
			
			System.out.println("people[min]: " + people[min]);
			System.out.println("people[max]: " + people[max]);
			System.out.println();
			if (people[min] + people[max] <= limit) {
				min++;
			}
			
			answer++;
		}
		
		System.out.println("answer: " + answer);
		return answer;
		
		// *테스트 케이스는 통과하나, 채점시 시간초과 에러
        /* int answer = 0;
        Set<Integer> rescuePeople = null;
        Integer[] arr = Arrays.stream(people).boxed().toArray(Integer[]::new);
        
        for (int i = 0; i < people.length; i++) {
        	for (int j = i + 1; j < people.length; j++) {
//        		System.out.println(people[i] + people[j]);
        		
        		if (people[i] + people[j] <= 100) {
        			System.out.println("people[i]: " + people[i]);
        			System.out.println("people[j]: " + people[j]);
        			System.out.println();
        			
        			rescuePeople = new HashSet<Integer>(Arrays.asList(arr));
        		}
        	}
        }
        
        if (rescuePeople == null) {
        	answer = people.length;
        } else {
        	answer = rescuePeople.size();
        }
        
        System.out.println("rescuePeople: " + rescuePeople);
        System.out.println("answer: " + answer);
        return answer; */
    }

}
