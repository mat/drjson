
require 'rspec'
require 'json'
require 'yajl'
require 'oj'

require 'drjson'

describe DrJson do
  
  def doctor
    DrJson.new(:debug => true)
  end

  describe "completion" do
  it "works" do
    doctor.repair("{").should == "{}"
  end

  it "insert the object value if absent" do
    doctor.repair('{"foo": ').should == '{"foo": null}'
  end

  it "closes array brackets" do
    doctor.repair("[42").should == "[42]"
  end
  it "inserts missing trailing array elements" do
    doctor.repair("[42,").should == "[42,null]"
    doctor.repair("[42,7,").should == "[42,7,null]"
  end

  it "works" do
    doctor.repair('{"foo": [42 ').should == '{"foo": [42 ]}'
    doctor.repair('{"foo": [ ').should == '{"foo": [ ]}'
  end
  it "works" do
    doctor.repair('{"foo": "bar').should == '{"foo": "bar"}'
    doctor.repair('{"foo": "ba').should == '{"foo": "ba"}'

    doctor.repair('{"foo": "').should == '{"foo": ""}'
    doctor.repair('{"foo": ').should == '{"foo": null}'
    doctor.repair('{"foo" ').should == '{"foo" :null}'
    doctor.repair('{"foo ').should == '{"foo ":null}'
    doctor.repair('{"foo').should == '{"foo":null}'

    doctor.repair('{"f').should == '{"f":null}'
    doctor.repair('{"').should == '{"":null}'
    doctor.repair('{').should == '{}'
  end
   end #completion

  ##################
  it "works" do
    doctor.repair("[]").should == "[]"
    doctor.repair("[42]").should == "[42]"
    doctor.repair('{"foo": "bar"}').should == '{"foo": "bar"}'
  end
  it "empty strings" do
    doctor.repair('{"":""}').should == '{"":""}'
  end
 it "works" do
    doctor.repair('{"foo": 42 }').should == '{"foo": 42 }'
    doctor.repair('{"foo": 42}').should == '{"foo": 42}'
  end
  it "multiline completion" do
    doctor.repair('{"foo": "bar').should == '{"foo": "bar"}'
  end
  it "works" do
    doctor.repair('{"foo": 42, "bar": 7 }').should == '{"foo": 42, "bar": 7 }'
  end
  it "works" do
    doctor.repair('{"foo": {"bar" : "baz"} }').should == '{"foo": {"bar" : "baz"} }'
    doctor.repair('{"foo": {"bar" : "baz').should == '{"foo": {"bar" : "baz"}}'
  end
  it "works" do
    doctor.repair('{"foo": [] }').should == '{"foo": [] }'
    doctor.repair('{"foo": [42] }').should == '{"foo": [42] }'
  end
  it "handles inclomplete (null|false|true) tokens" do
    DrJson.new.repair('[tru').should == '[]'
    DrJson.new.repair('[fals').should == '[]'
    DrJson.new.repair('[nul').should == '[]'
  end
  it "handles inclomplete (null|false|true) tokens" do
    DrJson.new.repair('[[tru').should == '[[]]'
    DrJson.new.repair('[[[fal').should == '[[[]]]'
    DrJson.new.repair('[[[[nul').should == '[[[[]]]]'
  end
   it "handles inclomplete (null|false|true) values" do
    DrJson.new.repair('{"foo":tru').should == '{"foo":null}'
    DrJson.new.repair('{"foo":{"bar":tru').should == '{"foo":{"bar":null}}'
  end
    it "handles inclomplete keys in pairs" do
    DrJson.new.repair('{"foo').should == '{"foo":null}'
  end
  it "works" do
    doctor.repair('{"foo": [42,7] }').should == '{"foo": [42,7] }'
    doctor.repair('{"foo": [42, 7] }').should == '{"foo": [42, 7] }'
    doctor.repair('{"foo": [42 ,7] }').should == '{"foo": [42 ,7] }'
    doctor.repair('{"foo": [42 , 7] }').should == '{"foo": [42 , 7] }'
    doctor.repair('{"foo": [42 , 7, 4711] }').should == '{"foo": [42 , 7, 4711] }'
  end

  it "supports all the null|false|true terminal symbols" do
    doctor.repair('[null]').should == '[null]'
    doctor.repair('[true]').should == '[true]'
    doctor.repair('[false]').should == '[false]'
  end

  context "numbers" do
    it "supports -" do
      doctor.repair('{"foo": -42 }').should == '{"foo": -42 }'
    end
    it "supports floats" do
      doctor.repair('{"foo": 7.42 }').should == '{"foo": 7.42 }'
    end
    it "supports exponents" do
      doctor.repair('{"foo": 1e-4 }').should == '{"foo": 1e-4 }'
      doctor.repair('{"foo": 1E-4 }').should == '{"foo": 1E-4 }'
      doctor.repair('{"foo": 1e+4 }').should == '{"foo": 1e+4 }'
      doctor.repair('{"foo": 1E+4 }').should == '{"foo": 1E+4 }'
      doctor.repair('{"foo": 1e4 }').should == '{"foo": 1e4 }'
      doctor.repair('{"foo": 1E4 }').should == '{"foo": 1E4 }'
    end
  end

    it "knows escape sequences" do
      doctor.repair('{"foo": "\"" }').should == '{"foo": "\"" }'
      doctor.repair('{"foo": "\\\\" }').should == '{"foo": "\\\\" }'
      doctor.repair('{"foo": "\/" }').should == '{"foo": "\/" }'
      doctor.repair('{"foo": "\b" }').should == '{"foo": "\b" }'
      doctor.repair('{"foo": "\f" }').should == '{"foo": "\f" }'
      doctor.repair('{"foo": "\n" }').should == '{"foo": "\n" }'
      doctor.repair('{"foo": "\r" }').should == '{"foo": "\r" }'
      doctor.repair('{"foo": "\t" }').should == '{"foo": "\t" }'
      doctor.repair('{"foo": "\u4711" }').should == '{"foo": "\u4711" }'
      doctor.repair('{"foo": "\ubeef" }').should == '{"foo": "\ubeef" }'
    end

  it "does not break on unexpected input, it tries to fix it" do
    broken_json ='{"foo": ["beef" {][] senseless'
    repaired_json = '{"foo": ["beef" ]}'
    DrJson.new.repair(broken_json).should == repaired_json
  end

  it "indicates unexpected input in debug mode" do
    broken_json ='{"foo": "beef" {'
    lambda {DrJson.new(:debug => true).repair(broken_json)}.should raise_error DrJson::UnexpectedTokenError
  end

  context "pass-through behavior for real life files" do
    json_files = Dir.glob("spec/fixtures/yajl-ruby/*.json")

    json_files.each do |file|
    describe "#{file}" do
      #it "is parseable with JSON: #{file}" do
      #  JSON.parse(File.read(file))
      #end
      it "is parseable with Oj: #{file}" do
        Oj.load(File.read(file))
      end
      #it "is parseable with Yajl: #{file}" do
      #  Yajl::Parser.parse(File.read(file))
      #end
      it "does pass through correct, real life file #{file}" do
        test_file(file)
      end
    end
    end
  end

  def test_file(file_name)
    json_str = File.read (file_name)
    repaired = doctor.repair(json_str)
    repaired.should == json_str
  end
end

