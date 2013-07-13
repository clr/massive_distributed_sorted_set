require File.expand_path('../helper', __FILE__)

# There aren't many things we can do with this POC.  We want to be able
# to add a score, move a score, and retrieve a page of results.
class TestApi < Test::Unit::TestCase
  def setup
    FakeWeb.register_uri :post, "http://127.0.0.1:8000/score", :body => "{player: 1, score: 1234, rank: 67}", :status => ["200", "OK"]
  end

  def test_add_score
    test_body = ""
    Net::HTTP.start('127.0.0.1','8000'){|req| test_body = req.post("/score", "{player: 1, score: 1234}").body}
    assert_equal "{player: 1, score: 1234, rank: 67}", test_body
  end
end
