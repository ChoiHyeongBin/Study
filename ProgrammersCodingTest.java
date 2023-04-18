package codingTest;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.TextStyle;
import java.util.Locale;

public class ProgrammersCodingTest {

	public static void main(String[] args) {
		int a = 5;
		int b = 24;
		
		solution(a, b);
	}

	// LV1 2016년 (*너무 느림, 라이브러리 안쓰고 구현해야할 듯?)
	public static String solution(int a, int b) {
        String answer = "";
        
        LocalDate date = LocalDate.of(2016, a, b);
        System.out.println("date : " + date);
        
        DayOfWeek dayOfWeek = date.getDayOfWeek();
        
        System.out.println(dayOfWeek.getDisplayName(TextStyle.SHORT, Locale.US).toUpperCase());
        
        answer = dayOfWeek.getDisplayName(TextStyle.SHORT, Locale.US).toUpperCase();
        return answer;
    }
}
