package codingTest;

public class ProgrammersCodingTest {

	public static void main(String[] args) {
		int[] arrFood = new int[] {1, 7, 1, 2};
		
		solution(arrFood);
	}

	// 푸드 파이트 대회
	public static String solution(int[] food) {
        String answer = "";
        
        for (int i = 0; i < food.length; i++) {
        	// 물이 아닐때
        	if (i != 0) {
        		for (int j = 0; j < food[i] / 2; j++) {
        			answer += i;
        		}
        		
//        		if (food[i] % 2 == 0) {
//        			for (int j = 0; j < food[i] / 2; j++) {
//        				System.out.println(j);
//        				answer += i;
//        			}
//        			System.out.println();    				
//        		} else {
//        			
//        		}
        	}
        }
        
        answer += "0";
        
        for (int i = food.length - 1; i >= 0; i--) {
        	for (int j = 0; j < food[i] / 2; j++) {
    			answer += i;
    		}
        }
        
        System.out.println("answer : " + answer);
        return answer;
    }
	
}
