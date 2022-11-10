package aoc2021.day12;

import static java.lang.System.out;

/**
 * Dec 12
 */
public class Main {

  public static void main(String[] args) {
    out.println("Dec 12");
  }
}

record Cave(char name) {
    boolean isSmall() {
        return Character.isLowerCase(name);
    }

    boolean isBig() {
        return Character.isUpperCase(name);
    }
}
