class Kumite
{
  // One O(n) seen-map pass for any input size — the baseline branches on
  // length (O(n²) scan / O(n log n) sort / map) but each branch is just a
  // worse way to answer the same question.
  // Method name matches the kata stub/test exactly: findduplicatenumber.
  public static function findduplicatenumber(nums: Array<Int>): Null<Int> {
    var seen = new Map<Int, Bool>();
    for (n in nums) {
      if (seen.exists(n)) return n;
      seen.set(n, true);
    }
    return null;
  }
}
