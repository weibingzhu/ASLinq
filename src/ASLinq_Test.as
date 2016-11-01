package
{
	import flash.display.Sprite;
	
	public class ASLinq_Test extends Sprite
	{
		public function ASLinq_Test()
		{
			var test : UnitTests = new UnitTests();
			test.test_except();
			test.test_aggregate();
			test.test_all();
			test.test_any();
			test.test_asEnumerable();
			test.test_average();
			test.test_cast();
			test.test_concat();
			test.test_defaultIfEmpty();
			test.test_distinct();
			test.test_elementAt();
			test.test_elementAtorDefault();
			test.test_except();
			test.test_first();
			test.test_firstOrDefault();
			test.test_getElementKeys();
			test.test_groupBy();
			test.test_groupJoin();
			test.test_intersects();
			test.test_join();
			test.test_last();
			test.test_lastOrDefault();
			test.test_max();
			test.test_min();
			test.test_nonPrimitives();
			test.test_ofType();
			test.test_where();

		}
	}
}