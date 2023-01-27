package org.example;

public class Solution {
    public static void main(String[] args) {
        var s = new Solution();
        var f0 = s.sumMatches(new Integer[]{100, 200, 400, 800}, 1000);
        System.out.println(f0);
        var f1 = s.sumMatches(new Integer[]{100, 200, 400, 800}, 1100);
        System.out.println(f1);
        var f2 = s.sumMatches(new Integer[]{-100, 200, 400, 800}, 300);
        System.out.println(f2);
    }

    /**
     * For a set of transactions, + or -, find if a target sum is found.
     * @param txs set of transactions
     * @param target budget
     * @return if found or not
     */
    boolean sumMatches(Integer[] txs, Integer target) {
        for (int i = 0; i < Math.pow(2, txs.length); i++) {
            var bin =  toBin(i, txs.length);
            var sum = 0;
            for (int j = 0; j < bin.length(); j++) {
                var bit = bin.charAt(j);
                if (bit == '1') {
                    sum += txs[j];
                }
            }
            System.out.println(sum);
            if (sum == target) return true;
        }
        return false;
    }

    String toBin(int i, int size) {
        var bin = new StringBuilder(Integer.toBinaryString(i));
        while (bin.length() < size) {
            bin.insert(0, "0");
        }
        return bin.toString();
    }
}
