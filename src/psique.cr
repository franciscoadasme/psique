require "chem"
require "colorize"
require "json"
require "option_parser"

OUTPUT_FORMATS = %w(pdb stride pymol vmd)
VERSION        = {{ `shards version "#{__DIR__}"`.chomp.stringify }}

def abort(message : String)
  STDERR.puts "psique: #{message}".colorize.red
  exit 1
end

def parse_output_format?(format : String) : Chem::Format | String | Nil
  case format.downcase
  when "json"   then "json"
  when "pdb"    then Chem::Format::PDB
  when "pymol"  then Chem::Format::PyMOL
  when "stride" then Chem::Format::Stride
  when "vmd"    then Chem::Format::VMD
  else               nil
  end
end

def write_json(io : IO, struc : Chem::Structure) : Nil
  JSON.build(io) do |json|
    json.object do
      json.field "secondary_structures" do
        json.array do
          struc.secondary_structures.select(&.[0].sec.regular?).each do |residues|
            json.object do
              json.field "sec", residues[0].sec.code.to_s
              json.field "start" do
                json.object do
                  json.field "chain", residues[0].chain.id.to_s
                  json.field "name", residues[0].name
                  json.field "insertion", residues[0].insertion_code.try(&.to_s)
                  json.field "number", residues[0].number
                end
              end
              json.field "end" do
                json.object do
                  json.field "chain", residues[-1].chain.id.to_s
                  json.field "name", residues[-1].name
                  json.field "insertion", residues[-1].insertion_code.try(&.to_s)
                  json.field "number", residues[-1].number
                end
              end
            end
          end
        end
      end
    end
  end
end

def write_json(path : String, struc : Chem::Structure) : Nil
  File.open(path, "w") do |file|
    write_json file, struc
  end
end

output_file = STDOUT
output_type = parse_output_format?(ENV.fetch("PSIQUE_FORMAT", "pdb")) ||
              abort "invalid format in PSIQUE_FORMAT environment variable"
beta = ""
OptionParser.parse do |parser|
  parser.banner = "Usage: psique [--format FORMAT] [-b|--beta PARAM] [-f|-o|--output FILE] PDB"
  parser.on(
    "--format FORMAT",
    "Set the output format. Must be one of (case-insensitive): pdb, \
    stride, pymol, or vmd. Defaults to PDB."
  ) do |str|
    output_type = parse_output_format?(str) || abort "invalid value for --format: #{str.inspect}"
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
  Chem::Protein::PSIQUE.assign structure

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

  case output_type
  when "json" then write_json output_file, structure
  else             structure.write output_file, output_type
  end
rescue ex : File::NotFoundError
  abort ex.message
rescue ex : Chem::ParseException
  abort ex.inspect_with_location
end
