package codingTest;

import java.util.HashSet;
import java.util.Set;

public class ProgrammersCodingTest {

    public static void main(String[] args) {
    	int[] elements = new int[] {7,9,1,1,4};
    	
    	solution(elements);
    }
	
    // LV2 연속 부분 수열 합의 개수
    public static int solution(int[] elements) {
        int answer = 0;
        // 1.7 부터는 앞에 선언된 타입으로 컴파일러에서 추측이 가능 하기 때문에 뒤에 생성자에서 제네릭 생략 가능하다. 
        // 이걸 다이아몬드 표현이라고 한다.
        Set<Integer> tempSet = new HashSet<Integer>();
        
        // 연속적인 수
        for (int i = 1; i <= elements.length; i++) {
        	// 배열 자릿수
        	for (int j = 0; j < elements.length; j++) {
        		int sum = 0;

        		for (int k = 0; k < i; k++) {
        			if (j + k > elements.length - 1) {
        				sum += elements[j + k - elements.length];
        			} else {
        				sum += elements[j + k];
        			}
                }
        		
        		tempSet.add(sum);
        		System.out.println("sum: " + sum);
            }
        	
        	System.out.println();
        }
        
        System.out.println("tempSet: " + tempSet.size());
        
        answer = tempSet.size();
        return answer;
    }
	
}
