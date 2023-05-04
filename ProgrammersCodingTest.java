package codingTest;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

public class ProgrammersCodingTest {

	public static void main(String[] args) {
		String[] name = new String[] {"may", "kein", "kain", "radi"};
		int[] yearning = new int[] {5, 10, 1, 3};
		String[][] photo = {{"may"},{"kein", "deny", "may"}, {"kon", "coni"}};
		
		solution(name, yearning, photo);
	}

	// LV1 추억 점수
	public static int[] solution(String[] name, int[] yearning, String[][] photo) {
        int[] answer = new int[photo.length];
        Map<String, Integer> tempMap = new HashMap<String, Integer>();
        System.out.println(Arrays.toString(answer));
        System.out.println(photo.length);
        
        for (int i = 0; i < name.length; i++) {
        	tempMap.put(name[i], yearning[i]);
        }
        
        for (int i = 0; i < photo.length; i++) {
        	int sum = 0;
        	
        	for (int j = 0; j < photo[i].length; j++) {
        		System.out.println("photo[i][j]: " + photo[i][j] + ", 존재 여부: " 
        			+ tempMap.containsKey(photo[i][j]));
        		
        		if (tempMap.containsKey(photo[i][j])) {
        			sum += tempMap.get(photo[i][j]);
        		}
        	}
        	System.out.println("sum: " + sum);
        	System.out.println();
        	answer[i] = sum;
        }
        
        System.out.println(Arrays.toString(answer));
        return answer;
    }
}
