package codingTest;

import java.util.Arrays;
import java.util.HashMap;

public class ProgrammersCodingTest {

	public static void main(String[] args) {
		String[] arrPlayers = new String[] {"mumu", "soe", "poe", "kai", "mine"};
		String[] arrCallings = new String[] {"kai", "kai", "mine", "mine"};
		
		solution(arrPlayers, arrCallings);
	}

	// LV1 달리기 경주
	public static String[] solution(String[] players, String[] callings) {
        String[] answer = new String[players.length];
        
        HashMap<String, Integer> mappedByPlayer = new HashMap<>();
        HashMap<Integer, String> mappedByRank = new HashMap<>();
        
        for (int i = 0; i < players.length; i++) {
        	mappedByPlayer.put(players[i], i);
        	mappedByRank.put(i, players[i]);
        }
        System.out.println("mappedByPlayer : " + mappedByPlayer);
        System.out.println("mappedByRank : " + mappedByRank);
        System.out.println();
        
        for (int i = 0; i < callings.length; i++) {
        	int currentRank = mappedByPlayer.get(callings[i]);	// 추월 유저 순위
        	String player = mappedByRank.get(currentRank);
        	System.out.println("currentRank : " + currentRank);
        	System.out.println("player : " + player);
        	
        	String frontPlayer = mappedByRank.get(currentRank - 1);
        	
        	mappedByPlayer.put(player, currentRank - 1);
        	mappedByPlayer.put(frontPlayer, currentRank);
        	
        	mappedByRank.put(currentRank - 1, player);
        	mappedByRank.put(currentRank, frontPlayer);
        }
        System.out.println("mappedByPlayer 222 : " + mappedByPlayer);
        System.out.println("mappedByRank 222 : " + mappedByRank);
        
        for (int i = 0; i < players.length; i++) {
        	answer[i] = mappedByRank.get(i);
        }
        
        System.out.println(Arrays.toString(answer));
        
        return answer;
    }
}
