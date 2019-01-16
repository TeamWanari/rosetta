import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/rosetta_generator.dart';

Builder rosettaStoneBuilder(BuilderOptions options) =>
    SharedPartBuilder([RosettaStoneBuilder()], 'rosetta');
