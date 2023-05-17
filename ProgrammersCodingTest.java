package codingTest;

public class ProgrammersCodingTest {

    public static void main(String[] args) {
    	int n = 8;
    	int a = 3;
    	int b = 4;
    	
    	solution(n, a, b);
    }
	
    // LV2 예상 대진표
    public static int solution(int n, int a, int b) {
        int answer = 0;
        
        /* 참가자의 번호가 짝수인 경우 참가자 번호 / 2 가 참가자의 라운드 번호가 되고
        참가자의 번호가 홀수인 경우 참가자 번호 / 2 + 1이 참가자의 라운드 번호가 된다

        라운드의 번호는 해당 라운드가 끝난 후 승자의 새 참가자 번호가 되기 때문에 위의 과정을 반복하여 a와 b가 한 라운드에 
        들어 있는 경우를 찾아내면 된다 */
        while (a != b) {
        	a = (a / 2) + (a % 2);
        	b = (b / 2) + (b % 2);
        	
        	System.out.println("a: " + a);
        	System.out.println("b: " + b);
        	System.out.println();
        	answer++;
        }
        
        System.out.println("answer: " + answer);
        
        /* List<Integer> linkNumList = new LinkedList<Integer>();

        for (int i = 1; i <= n; i++) {
        	linkNumList.add(i);
        }

        System.out.println("linkNumList: " + linkNumList);
        
        for (int i = 0; i < linkNumList.size(); i++) {
        	if ((i + i) + 1 < linkNumList.size()) {
        		System.out.println(linkNumList.get(i + i));
        		System.out.println(linkNumList.get((i + i) + 1));
        		System.out.println();
        		
        		if (linkNumList.get(i + i) < linkNumList.get((i + i) + 1)) {
        			// *a, b에 해당하면서 1명씩 줄여나갈 방법이 없음
        		}
        	}
        } */
        
        return answer;
    }

}
