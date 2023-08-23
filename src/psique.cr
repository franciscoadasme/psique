require "option_parser"
require "chem"

OUTPUT_FORMATS = %w(pdb stride pymol vmd)
VERSION        = {{ `shards version "#{__DIR__}"`.chomp.stringify }}

def abort(message : String)
  STDERR.puts "psique: #{message}"
  exit 1
end

output_file = STDOUT
output_type = ENV.fetch("PSIQUE_FORMAT", "pdb").downcase.tap do |format|
  unless format.in?(OUTPUT_FORMATS)
    abort "invalid format #{format.inspect} in PSIQUE_FORMAT environment variable"
  end
end
beta = ""
OptionParser.parse do |parser|
  parser.banner = "Usage: psique [--format FORMAT] [-b|--beta PARAM] [-f|-o|--output FILE] PDB"
  parser.on(
    "--format FORMAT",
    "Set the output format. Must be one of (case-insensitive): pdb, \
    stride, pymol, or vmd. Defaults to PDB."
  ) do |str|
    if (str = str.downcase).in?(OUTPUT_FORMATS)
      output_type = str
    else
      abort "invalid value for --format: #{str.inspect}"
    end
  end
  parser.on("-o OUTPUT", "--output OUTPUT", "Output file") do |str|
    output_file = str
  end
  parser.on("-f OUTPUT", "Alias for -o/--output. Compatible with STRIDE") do |str|
    output_file = str
  end
  parser.on(
    "-b PARAM",
    "--beta PARAM",
    "Write parameter value to PDB beta column. " \
    "Must be one of: rise, twist, or curvature"
  ) do |str|
    if str.in?("rise", "twist", "curvature")
      beta = str
    else
      abort "invalid value for -b/--beta: #{str.inspect}"
    end
  end
  parser.on("-h", "--help", "Show this help") do
    puts <<-HELP
      PSIQUE: Protein Secondary structure Identification on the basis of
      QUaternions and Electronic structure calculations

      PSIQUE is a geometry-based secondary structure assignment method
      that uses local helix parameters, quaternions, and a
      classification criterion derived from DFT calculations of
      polyalanine. The algorithm can identify common (alpha-, 3_10-,
      pi-helices and beta-strand) and rare (PP-II ribbon helix and
      gamma-helices) secondary structures, including handedness if
      appropriate.

      The information of the protein secondary structure is written in
      the PDB header. Special codes are used for some structures not
      included in the standard format: 11 for left-handed 3_10-helix and
      13 for left-handed pi-helix. Alternatively, the output can be
      written in other file formats that can be read in analysis and
      visualization packages.

      Check https://github.com/franciscoadasme/psique for more
      information.
      HELP
    puts
    puts parser
    exit
  end
  parser.on("--cite", "Show citation for article") do
    puts <<-CITE
      Adasme-Carreño, F., Caballero, J., & Ireta, J. (2021). PSIQUE: \
      Protein Secondary Structure Identification on the Basis of \
      Quaternions and Electronic Structure Calculations. Journal of \
      Chemical Information and Modeling, 61(4), 1789-1800. \
      https://doi.org/10.1021/acs.jcim.0c01343
      CITE
    exit
  end
  parser.on("--version", "show version") do
    puts "PSIQUE #{VERSION}"
    exit
  end

  parser.invalid_option do |flag|
    STDERR.puts "psique: #{flag} is not a valid option."
    STDERR.puts parser
    exit
  end
end

abort "missing input file" unless input_file = ARGV[0]?

begin
  structure = Chem::Structure.from_pdb input_file
  structure.each_residue do |residue|
    case beta
    when "curvature"
      curvature = 0.0
      if (h1 = residue.pred?.try(&.hlxparams)) &&
         (h2 = residue.hlxparams) &&
         (h3 = residue.succ?.try(&.hlxparams))
        dprev = Chem::Spatial.distance h1.to_q, h2.to_q
        dnext = Chem::Spatial.distance h2.to_q, h3.to_q
        curvature = ((dprev + dnext) / 2).degrees
      end
      residue.each_atom &.temperature_factor=(curvature)
    when "rise"
      rise = residue.hlxparams.try(&.pitch) || 0.0
      residue.each_atom &.temperature_factor=(rise)
    when "twist"
      twist = residue.hlxparams.try(&.twist) || 0.0
      residue.each_atom &.temperature_factor=(twist)
    end
  end
  Chem::Protein::PSIQUE.assign structure

  case output_type
  when "pymol"  then structure.to_pymol output_file
  when "vmd"    then structure.to_vmd output_file
  when "stride" then structure.to_stride output_file
  when "pdb"    then structure.to_pdb output_file
  else               raise "BUG: unreachable"
  end
rescue ex : Chem::ParseException
  abort ex.inspect_with_location
end
