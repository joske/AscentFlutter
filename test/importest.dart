// @dart=2.9
import 'package:ascent/ascent.dart';
import 'package:ascent/import.dart';
import 'package:test/test.dart';

void main() {
  test('Import from json', () {
    String data = '''[{
		"ascentId": 4539486,
		"areaName": null,
		"areaSlug": null,
		"cragName": "Rochers de la vierge",
		"cragSlug": "rochers-de-la-vierge",
		"sectorSlug": "arete-de-chirmont",
		"zlaggableName": "Too fat for tufas",
		"zlaggableSlug": "too-fat-for-tufas",
		"countrySlug": "belgium",
		"userAvatar": "gallery/19961.jpg",
		"userName": "Jos Dehaes",
		"userSlug": "jos-dehaes-y2hq5",
		"date": "2017-11-05T00:00:00+00:00",
		"difficulty": "7c",
		"gradeIndex": 27,
		"comment": "Great route with 3 cruxes. Technical climbing on small holds. Thanks Ivan!",
		"isPrivateComment": false,
		"traditional": false,
		"project": false,
		"isHard": false,
		"isSoft": false,
		"firstAscent": false,
		"secondGo": false,
		"type": "rp",
		"notes": "Great route with 3 cruxes. Technical climbing on small holds. Thanks Ivan!",
		"rating": 5
	}, {
		"ascentId": 4455764,
		"areaName": null,
		"areaSlug": null,
		"cragName": "Bomal",
		"cragSlug": "bomal",
		"sectorSlug": "calvaire",
		"zlaggableName": "Toxic Climax",
		"zlaggableSlug": "toxic-climax",
		"countrySlug": "belgium",
		"userAvatar": "gallery/19961.jpg",
		"userName": "Jos Dehaes",
		"userSlug": "jos-dehaes-y2hq5",
		"date": "2017-09-03T00:00:00+00:00",
		"difficulty": "7b+",
		"gradeIndex": 26,
		"comment": "did not expect to do it today, pure power endurance",
		"isPrivateComment": false,
		"traditional": false,
		"project": false,
		"isHard": false,
		"isSoft": false,
		"firstAscent": false,
		"secondGo": false,
		"type": "rp",
		"notes": "did not expect to do it today, pure power endurance",
		"rating": 5
	}]''';
    List<Ascent> list = CsvImporter().parseEightAJson(data);
    expect(list.length, 2);
    expect(list[0].route.name, "Too fat for tufas");
    expect(list[1].route.name, "Toxic Climax");
    print(list[0]);
    print(list[1]);
  });
}
