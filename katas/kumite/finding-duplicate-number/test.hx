// Tests are written using https://github.com/haxe-utest/utest
// Verbatim mirror of the platform suite (the authoritative run lives on Codewars;
// haxe is not installed locally — see README for the transliteration check).
import utest.Assert;
import Solution;

class SolutionTest extends utest.Test {
  function testExample() {
    Assert.equals(3, Kumite.findduplicatenumber([1,2,3,3,5]));
    Assert.equals(22, Kumite.findduplicatenumber([4,2,46,1,5,26,263,51,463,11,41,44,3,45,43,33,32,514,451,23,465,456,21,31,53,444,16,442,36,441,42,516,52,13,333,316,34,22,111,6,136,61,335,424,22]));
    Assert.equals(234, Kumite.findduplicatenumber([418,300,968,268,215,70,11,716,683,114,411,705,748,942,295,929,365,769,591,473,717,907,804,397,731,234,939,144,745,631,662,119,463,287,34,210,887,307,343,515,410,401,178,918,430,205,569,234,558,602,790,369,696,854,750,450,251,290,87,162,49,425,83,266,788,562,821,54,326,8,772,911,545,400,76,785,495,197,987,278,282,829,294,880,800,91,338,526,136,860,649,358,243,254,792,199,126,100,567,269]));
  }
}
