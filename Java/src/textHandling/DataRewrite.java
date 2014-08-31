package textHandling;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Scanner;

public class DataRewrite {

	static int startDate = 20040101;
	static int endDate = 20041231;

	static String[] fileInNames = { "01400.txt", "02225.txt", "02836.txt" };
	static String[] fileOutNames = { "Ekofisk_data.txt", "Ostersund_data.txt",
			"Sodankyla_data.txt" };

	public static void main(String[] args) throws IOException {
		for (int j = 0; j < 3; j++) {
			StringBuilder sb = null;
			Scanner s = null;
			/**
			 * extract wind speed and pressure by date:
			 */
			try {
				s = new Scanner(new BufferedReader(new FileReader(
						fileInNames[j])));
				sb = new StringBuilder();
				System.out.println("investigating next...");
				while (s.hasNextLine()) {
					String line = s.nextLine();
					char[] letter = line.toCharArray();
					if (letter[0] == '#') {
						String date = new String(letter, 6, 13 - 6 + 1);
						// System.out.println("date: " + date);
						if (Integer.parseInt(date) > startDate
								&& Integer.parseInt(date) < endDate) {
							sb.append(date);
							sb.append("\n");
							String tot = new String(letter, 20, 23 - 20 + 1);
							tot = tot.replaceAll("\\s+", "");
							int n = Integer.parseInt(tot);
							for (int i = 0; i < n; i++) {
								String line2 = s.nextLine();
								char[] letter2 = line2.toCharArray();
								String type = new String(letter2, 0, 1 - 0 + 1);
								// System.out.println(type);
								int m = Integer.parseInt(type);
								if (m == 22) {
									String p = new String(letter2, 2, 7 - 2 + 1);
									p = p.replaceAll("\\s+", "");
									if (p.length() > 4) {
										sb.append(p);// pressure in Pa
										sb.append("\n");
									}
									String w = new String(letter2, 31,
											35 - 31 + 1);
									w = w.replaceAll("\\s+", "");
									int v = Integer.parseInt(w);
									String a = new String(letter2, 26,
											30 - 26 + 1);
									a = a.replaceAll("\\s+", "");
									int t = Integer.parseInt(a);
									double u = v * Math.cos(Math.toRadians(t))
											/ 10;
									sb.append(u);// wind speed (projected onto
													// the
													// line) in m/s
									sb.append("\n");
								}
							}
						}
					}
				}
				/**
				 * remove double values
				 */
				String master = sb.toString();
				String[] next = master.split("\n");
				int size = next.length;
				StringBuilder sb2 = new StringBuilder();
				for (int i = 0; i < size - 1; i++) {
					if (next[i].length() != next[i + 1].length()) {
						sb2.append(next[i] + "\t");
						if (next[i].contains(".")) {
							sb2.append("\n");
						}
					}
				}
				StringBuilder sb3 = new StringBuilder();
				String newMaster = sb2.toString();
				String[] next2 = newMaster.split("\n");
				int newSize = next2.length;
				for (int i = 0; i < newSize; i++) {
					String[] elements = next2[i].split("\t");
					if (elements.length > 2) {
						sb3.append(next2[i]);
						sb3.append("\n");
					}
				}

				/**
				 * remove data with same date
				 */

				StringBuilder sb4 = new StringBuilder();
				String newMaster2 = sb3.toString();
				String[] next3 = newMaster2.split("\n");
				int newSize2 = next3.length;
				for (int i = 0; i < newSize2 - 1; i++) {
					String[] elements2 = next3[i].split("\t");
					String[] elements3 = next3[i + 1].split("\t");
					if (Integer.parseInt(elements2[0]) != Integer
							.parseInt(elements3[0])) {
						sb4.append(next3[i]);
						sb4.append("\n");
					}
				}

				String finalString = sb4.toString();
				writeToFile(finalString, fileOutNames[j]);
				String[] finalArray = finalString.split("\n");
				System.out.println(fileOutNames[j] + ": " + finalArray.length);
			} finally {

				if (s != null) {
					s.close();
				}
			}
		}
		System.out.println("Dates: " + startDate + "-" + endDate);

		/**
		 * create one big data file:
		 */

		System.out.println("Creating Collected_Data.txt...");
		StringBuilder sb5 = new StringBuilder();
		Scanner s2 = null;
		Scanner s3 = null;
		String[] lastEkoValue = null;

		try {
			s2 = new Scanner(new BufferedReader(new FileReader(
					"Ekofisk_data.txt")));
			s3 = new Scanner(new BufferedReader(new FileReader(
					"Sodankyla_data.txt")));
			String sodLine = s3.nextLine();
			String ekoLine = s2.nextLine();
			lastEkoValue = ekoLine.split("\t");
			while (s2.hasNext()) {
				String[] sodWords = sodLine.split("\t");
				String[] ekoWords = ekoLine.split("\t");
				if (Integer.parseInt(sodWords[0]) == Integer
						.parseInt(ekoWords[0])) {
					sb5.append(sodWords[0] + "\t" + ekoWords[1] + "\t"
							+ ekoWords[2] + "\t" + sodWords[1] + "\t"
							+ sodWords[2]);
					sb5.append("\n");
					sodLine = s3.nextLine();
					ekoLine = s2.nextLine();
				} 
				if(Integer.parseInt(sodWords[0]) > Integer
						.parseInt(ekoWords[0])){
					sb5.append(sodWords[0] + "\t" + ekoWords[1] + "\t"
							+ ekoWords[2] + "\t" + sodWords[1] + "\t"
							+ sodWords[2]);
					sb5.append("\n");
					ekoLine = s2.nextLine();
				}
				if(Integer.parseInt(sodWords[0]) < Integer
						.parseInt(ekoWords[0])){
					sb5.append(sodWords[0] + "\t" + ekoWords[1] + "\t"
							+ ekoWords[2] + "\t" + sodWords[1] + "\t"
							+ sodWords[2]);
					sb5.append("\n");
					sodLine = s3.nextLine();
				}

			}
			while (s3.hasNextLine()){
				String[] sodWords = sodLine.split("\t");
				sb5.append(sodWords[0] + "\t" + lastEkoValue[1] + "\t"
						+ lastEkoValue[2] + "\t" + sodWords[1] + "\t"
						+ sodWords[2]);
				sb5.append("\n");
				sodLine = s3.nextLine();
				
			}

			String finalString2 = sb5.toString();
			writeToFile(finalString2, "Collected_Data.txt");
			String[] finalArray2 = finalString2.split("\n");
			System.out.println("Collected_Data.txt" + ": " + finalArray2.length);
		} finally {
			if (s2 != null) {
				s2.close();
			}
			if (s3 != null) {
				s3.close();
			}
		}
	}

	private static void writeToFile(String input, String fileOutName) {
		try {

			File file = new File(fileOutName);

			// if file doesn't exists, then create it
			if (!file.exists()) {
				file.createNewFile();
			}

			FileWriter fw = new FileWriter(file.getAbsoluteFile());
			BufferedWriter bw = new BufferedWriter(fw);
			bw.write(input);
			bw.close();

			System.out.println("Done");

		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
