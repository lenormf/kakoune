#pragma once

#include "units.hh"
#include "utils.hh"
#include "vector.hh"

namespace Kakoune
{

class Buffer;

struct LineModification
{
    LineCount old_line; // line position in the old buffer
    LineCount new_line; // new line position
    LineCount num_removed; // number of lines removed (including this one)
    LineCount num_added; // number of lines added (including this one)

    LineCount diff() const { return new_line - old_line + num_added - num_removed; }
};

Vector<LineModification> compute_line_modifications(const Buffer& buffer, size_t timestamp);

}
