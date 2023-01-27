package org.example;

public class Main {

    static void flood(int[][] world, int i, int j, int c) {
        world[i][j] = -1;
        if (j < world[i].length - 1 && world[i][j + 1] == c) flood(world, i, j + 1, c);
        if (i < world.length - 1 && world[i + 1][j] == c) flood(world, i + 1, j, c);
        if (j - 1 >= 0 && world[i][j - 1] == c) flood(world, i, j - 1, c);
        if (i - 1 >= 0 && world[i - 1][j] == c) flood(world, i - 1, j, c);
    }

    static int countCountries(int[][] world) {
        int n = 0;
        for (int i = 0; i < world.length; i++) {

            for (int j = 0; j < world[i].length; j++) {
                if (world[i][j] != -1) { // new country
                    n++;
                    flood(world, i, j, world[i][j]);
                }
            }
        }
        return n;
    }

    public static void main(String[] args) {
        var noWorld = new int[][]{
                {-1, -1, -1, -1, -1},
                {-1, -1, -1, -1, -1},
                {-1, -1, -1, -1, -1}
        };

        var c1 = countCountries(noWorld);
        System.out.println(c1);

        var singleWorld = new int[][]{
                {1, 1, 1, 1, 1},
                {1, 1, 1, 1, 1},
                {1, 1, 1, 1, 1}
        };

        var c2 = countCountries(singleWorld);
        System.out.println(c2);

        var world = new int[][]{
                {1, 1, 1, 3, 2},
                {1, 2, 3, 3, 3},
                {1, 1, 4, 4, 3}
        };
//        System.out.println(countCountries(world));

        System.out.println(countCountries(world));
    }

}