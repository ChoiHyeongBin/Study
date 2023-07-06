package codingTest;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;

public class ProgrammersCodingTest {

    public static void main(String[] args) {
    	String[][] clothes = {{"yellow_hat", "headgear"}, {"blue_sunglasses", "eyewear"}, {"green_turban", "headgear"}};
    	
    	solution(clothes);
    }
	
    // LV2 의상
    public static int solution(String[][] clothes) {
        int answer = 1;
        
        // 1. 옷을 종류별로 구분하기
        HashMap<String, Integer> tempMap = new HashMap<>();
        
        for (String[] clothe : clothes) {
        	String type = clothe[1];
        	System.out.println("type: " + type);
        	
        	// getOrDefault: 찾는 키가 존재한다면 찾는 키의 값을 반환하고, 없다면 기본 값을 반환하는 메서드
        	tempMap.put(type, tempMap.getOrDefault(type, 0) + 1);
        	System.out.println("tempMap: " + tempMap);
        }
        
        System.out.println();
        System.out.println("tempMap 222: " + tempMap);
        
        // 2. 입지 않는 경우를 추가하여 모든 조합 계산하기
        // Iterator: 인덱스가 없는 자료구조의 경우 그 안의 데이터를 돌기 위해서 사용
        Iterator<Integer> it = tempMap.values().iterator();
        
        while (it.hasNext()) {
//        	System.out.println(it.next().intValue());
        	
        	answer *= it.next().intValue() + 1;
        }
        
        /* for (int i = 0; i < clothes.length; i++) {
        	System.out.println(clothes[i][0]);
        } */
        
        System.out.println("answer: " + (answer - 1));
        // 3. 아무종류의 옷도 입지 않는 경우 제외하기
        return answer - 1;
    }
	
}
