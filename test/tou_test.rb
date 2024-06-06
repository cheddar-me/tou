require "test_helper"

class TouTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Tou::VERSION
  end

  def test_generates_uuids_with_known_time_and_entropy_source
    rng = Random.new(42)
    t = Time.utc(2024, 6, 7)
    uids = 10.times.map { Tou.uuid(random: rng, time: t) }
    ref = [
      "061a417b-0e60-4006-9ce1-5fb33deacb5c",
      "061a417b-0e60-400e-95f5-2e6af463bb47",
      "061a417b-0e60-400c-ae41-99142ccb9866",
      "061a417b-0e60-4009-9822-72d241ef27d6",
      "061a417b-0e60-400a-91de-0eca55917557",
      "061a417b-0e60-4004-ad6d-5563ace29967",
      "061a417b-0e60-4007-be44-b582a0a0a695",
      "061a417b-0e60-4004-bd70-0e01034cf857",
      "061a417b-0e60-400b-b51a-d59dfd44f025",
      "061a417b-0e60-4001-8933-00bf148c2ebb"
    ]
    assert_equal ref, uids
  end

  def test_generates_uuids_with_correct_format_and_of_variant_4
    uids = 10.times.map { Tou.uuid }
    uids.each do |uid|
      # Assert 4 at the nibble position explicitly
      assert_match /^[0-9a-f]{8}\-[0-9a-f]{4}\-4[0-9a-f]{3}\-[0-9a-f]{4}\-[0-9a-f]{12}$/, uid
    end
  end
end
