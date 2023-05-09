package codingTest;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.OptionalInt;
import java.util.stream.IntStream;

public class ProgrammersCodingTest {

	public static void main(String[] args) {
//		int[] arrNum = new int[] {1,3,2,4,2};
		int[] arrNum = new int[] {1,2,3,4,5};
		
		solution(arrNum);
	}

	// LV1 모의고사
	public static int[] solution(int[] answers) {
        int[] answer = new int[3];
        List<Integer> highPerson = new ArrayList<Integer>();
        int[] first  = new int[] {1, 2, 3, 4, 5};
        int[] second = new int[] {2, 1, 2, 3, 2, 4, 2, 5};
        int[] third  = new int[] {3, 3, 1, 1, 2, 2, 4, 4, 5, 5};
        
        answer[0] = proc(first, answers);
        answer[1] = proc(second, answers);
        answer[2] = proc(third, answers);

        IntStream intStream = Arrays.stream(answer);
        OptionalInt optionalInt = intStream.max();
        int maxAsInt = optionalInt.getAsInt();
        
        for (int o = 0; o < answer.length; o++) {
        	if (answer[o] == maxAsInt) {
        		highPerson.add(o + 1);
        	}
        }
        
        answer = highPerson.stream().mapToInt(Integer::intValue).toArray();
        return answer;
    }
	
	public static int proc(int[] person, int[] answers) {
		int cnt = 0;	// 카운트
		int i = 0;		// 수포자 인덱스
        int j = 0;		// 정답 인덱스
        
        while (true) {
        	if (i == person.length) {
        		i = 0;
        	}
        	
        	if (j == answers.length) {
        		break;
        	}
        	
        	if (person[i] == answers[j]) {
        		cnt++;
        	}
        	
        	i++;
        	j++;
        }
		
		return cnt;
	}
}
