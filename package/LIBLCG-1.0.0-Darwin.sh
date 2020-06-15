#!/bin/sh

# Display usage
cpack_usage()
{
  cat <<EOF
Usage: $0 [options]
Options: [defaults in brackets after descriptions]
  --help            print this message
  --version         print cmake installer version
  --prefix=dir      directory in which to install
  --include-subdir  include the LIBLCG-1.0.0-Darwin subdirectory
  --exclude-subdir  exclude the LIBLCG-1.0.0-Darwin subdirectory
  --skip-license    accept license
EOF
  exit 1
}

cpack_echo_exit()
{
  echo $1
  exit 1
}

# Display version
cpack_version()
{
  echo "LIBLCG Installer Version: 1.0.0, Copyright (c) Humanity"
}

# Helper function to fix windows paths.
cpack_fix_slashes ()
{
  echo "$1" | sed 's/\\/\//g'
}

interactive=TRUE
cpack_skip_license=FALSE
cpack_include_subdir=""
for a in "$@"; do
  if echo $a | grep "^--prefix=" > /dev/null 2> /dev/null; then
    cpack_prefix_dir=`echo $a | sed "s/^--prefix=//"`
    cpack_prefix_dir=`cpack_fix_slashes "${cpack_prefix_dir}"`
  fi
  if echo $a | grep "^--help" > /dev/null 2> /dev/null; then
    cpack_usage 
  fi
  if echo $a | grep "^--version" > /dev/null 2> /dev/null; then
    cpack_version 
    exit 2
  fi
  if echo $a | grep "^--include-subdir" > /dev/null 2> /dev/null; then
    cpack_include_subdir=TRUE
  fi
  if echo $a | grep "^--exclude-subdir" > /dev/null 2> /dev/null; then
    cpack_include_subdir=FALSE
  fi
  if echo $a | grep "^--skip-license" > /dev/null 2> /dev/null; then
    cpack_skip_license=TRUE
  fi
done

if [ "x${cpack_include_subdir}x" != "xx" -o "x${cpack_skip_license}x" = "xTRUEx" ]
then
  interactive=FALSE
fi

cpack_version
echo "This is a self-extracting archive."
toplevel="`pwd`"
if [ "x${cpack_prefix_dir}x" != "xx" ]
then
  toplevel="${cpack_prefix_dir}"
fi

echo "The archive will be extracted to: ${toplevel}"

if [ "x${interactive}x" = "xTRUEx" ]
then
  echo ""
  echo "If you want to stop extracting, please press <ctrl-C>."

  if [ "x${cpack_skip_license}x" != "xTRUEx" ]
  then
    more << '____cpack__here_doc____'
GNU GENERAL PUBLIC LICENSE
                       Version 3, 29 June 2007

 Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
 Everyone is permitted to copy and distribute verbatim copies
 of this license document, but changing it is not allowed.

                            Preamble

  The GNU General Public License is a free, copyleft license for
software and other kinds of works.

  The licenses for most software and other practical works are designed
to take away your freedom to share and change the works.  By contrast,
the GNU General Public License is intended to guarantee your freedom to
share and change all versions of a program--to make sure it remains free
software for all its users.  We, the Free Software Foundation, use the
GNU General Public License for most of our software; it applies also to
any other work released this way by its authors.  You can apply it to
your programs, too.

  When we speak of free software, we are referring to freedom, not
price.  Our General Public Licenses are designed to make sure that you
have the freedom to distribute copies of free software (and charge for
them if you wish), that you receive source code or can get it if you
want it, that you can change the software or use pieces of it in new
free programs, and that you know you can do these things.

  To protect your rights, we need to prevent others from denying you
these rights or asking you to surrender the rights.  Therefore, you have
certain responsibilities if you distribute copies of the software, or if
you modify it: responsibilities to respect the freedom of others.

  For example, if you distribute copies of such a program, whether
gratis or for a fee, you must pass on to the recipients the same
freedoms that you received.  You must make sure that they, too, receive
or can get the source code.  And you must show them these terms so they
know their rights.

  Developers that use the GNU GPL protect your rights with two steps:
(1) assert copyright on the software, and (2) offer you this License
giving you legal permission to copy, distribute and/or modify it.

  For the developers' and authors' protection, the GPL clearly explains
that there is no warranty for this free software.  For both users' and
authors' sake, the GPL requires that modified versions be marked as
changed, so that their problems will not be attributed erroneously to
authors of previous versions.

  Some devices are designed to deny users access to install or run
modified versions of the software inside them, although the manufacturer
can do so.  This is fundamentally incompatible with the aim of
protecting users' freedom to change the software.  The systematic
pattern of such abuse occurs in the area of products for individuals to
use, which is precisely where it is most unacceptable.  Therefore, we
have designed this version of the GPL to prohibit the practice for those
products.  If such problems arise substantially in other domains, we
stand ready to extend this provision to those domains in future versions
of the GPL, as needed to protect the freedom of users.

  Finally, every program is threatened constantly by software patents.
States should not allow patents to restrict development and use of
software on general-purpose computers, but in those that do, we wish to
avoid the special danger that patents applied to a free program could
make it effectively proprietary.  To prevent this, the GPL assures that
patents cannot be used to render the program non-free.

  The precise terms and conditions for copying, distribution and
modification follow.

                       TERMS AND CONDITIONS

  0. Definitions.

  "This License" refers to version 3 of the GNU General Public License.

  "Copyright" also means copyright-like laws that apply to other kinds of
works, such as semiconductor masks.

  "The Program" refers to any copyrightable work licensed under this
License.  Each licensee is addressed as "you".  "Licensees" and
"recipients" may be individuals or organizations.

  To "modify" a work means to copy from or adapt all or part of the work
in a fashion requiring copyright permission, other than the making of an
exact copy.  The resulting work is called a "modified version" of the
earlier work or a work "based on" the earlier work.

  A "covered work" means either the unmodified Program or a work based
on the Program.

  To "propagate" a work means to do anything with it that, without
permission, would make you directly or secondarily liable for
infringement under applicable copyright law, except executing it on a
computer or modifying a private copy.  Propagation includes copying,
distribution (with or without modification), making available to the
public, and in some countries other activities as well.

  To "convey" a work means any kind of propagation that enables other
parties to make or receive copies.  Mere interaction with a user through
a computer network, with no transfer of a copy, is not conveying.

  An interactive user interface displays "Appropriate Legal Notices"
to the extent that it includes a convenient and prominently visible
feature that (1) displays an appropriate copyright notice, and (2)
tells the user that there is no warranty for the work (except to the
extent that warranties are provided), that licensees may convey the
work under this License, and how to view a copy of this License.  If
the interface presents a list of user commands or options, such as a
menu, a prominent item in the list meets this criterion.

  1. Source Code.

  The "source code" for a work means the preferred form of the work
for making modifications to it.  "Object code" means any non-source
form of a work.

  A "Standard Interface" means an interface that either is an official
standard defined by a recognized standards body, or, in the case of
interfaces specified for a particular programming language, one that
is widely used among developers working in that language.

  The "System Libraries" of an executable work include anything, other
than the work as a whole, that (a) is included in the normal form of
packaging a Major Component, but which is not part of that Major
Component, and (b) serves only to enable use of the work with that
Major Component, or to implement a Standard Interface for which an
implementation is available to the public in source code form.  A
"Major Component", in this context, means a major essential component
(kernel, window system, and so on) of the specific operating system
(if any) on which the executable work runs, or a compiler used to
produce the work, or an object code interpreter used to run it.

  The "Corresponding Source" for a work in object code form means all
the source code needed to generate, install, and (for an executable
work) run the object code and to modify the work, including scripts to
control those activities.  However, it does not include the work's
System Libraries, or general-purpose tools or generally available free
programs which are used unmodified in performing those activities but
which are not part of the work.  For example, Corresponding Source
includes interface definition files associated with source files for
the work, and the source code for shared libraries and dynamically
linked subprograms that the work is specifically designed to require,
such as by intimate data communication or control flow between those
subprograms and other parts of the work.

  The Corresponding Source need not include anything that users
can regenerate automatically from other parts of the Corresponding
Source.

  The Corresponding Source for a work in source code form is that
same work.

  2. Basic Permissions.

  All rights granted under this License are granted for the term of
copyright on the Program, and are irrevocable provided the stated
conditions are met.  This License explicitly affirms your unlimited
permission to run the unmodified Program.  The output from running a
covered work is covered by this License only if the output, given its
content, constitutes a covered work.  This License acknowledges your
rights of fair use or other equivalent, as provided by copyright law.

  You may make, run and propagate covered works that you do not
convey, without conditions so long as your license otherwise remains
in force.  You may convey covered works to others for the sole purpose
of having them make modifications exclusively for you, or provide you
with facilities for running those works, provided that you comply with
the terms of this License in conveying all material for which you do
not control copyright.  Those thus making or running the covered works
for you must do so exclusively on your behalf, under your direction
and control, on terms that prohibit them from making any copies of
your copyrighted material outside their relationship with you.

  Conveying under any other circumstances is permitted solely under
the conditions stated below.  Sublicensing is not allowed; section 10
makes it unnecessary.

  3. Protecting Users' Legal Rights From Anti-Circumvention Law.

  No covered work shall be deemed part of an effective technological
measure under any applicable law fulfilling obligations under article
11 of the WIPO copyright treaty adopted on 20 December 1996, or
similar laws prohibiting or restricting circumvention of such
measures.

  When you convey a covered work, you waive any legal power to forbid
circumvention of technological measures to the extent such circumvention
is effected by exercising rights under this License with respect to
the covered work, and you disclaim any intention to limit operation or
modification of the work as a means of enforcing, against the work's
users, your or third parties' legal rights to forbid circumvention of
technological measures.

  4. Conveying Verbatim Copies.

  You may convey verbatim copies of the Program's source code as you
receive it, in any medium, provided that you conspicuously and
appropriately publish on each copy an appropriate copyright notice;
keep intact all notices stating that this License and any
non-permissive terms added in accord with section 7 apply to the code;
keep intact all notices of the absence of any warranty; and give all
recipients a copy of this License along with the Program.

  You may charge any price or no price for each copy that you convey,
and you may offer support or warranty protection for a fee.

  5. Conveying Modified Source Versions.

  You may convey a work based on the Program, or the modifications to
produce it from the Program, in the form of source code under the
terms of section 4, provided that you also meet all of these conditions:

    a) The work must carry prominent notices stating that you modified
    it, and giving a relevant date.

    b) The work must carry prominent notices stating that it is
    released under this License and any conditions added under section
    7.  This requirement modifies the requirement in section 4 to
    "keep intact all notices".

    c) You must license the entire work, as a whole, under this
    License to anyone who comes into possession of a copy.  This
    License will therefore apply, along with any applicable section 7
    additional terms, to the whole of the work, and all its parts,
    regardless of how they are packaged.  This License gives no
    permission to license the work in any other way, but it does not
    invalidate such permission if you have separately received it.

    d) If the work has interactive user interfaces, each must display
    Appropriate Legal Notices; however, if the Program has interactive
    interfaces that do not display Appropriate Legal Notices, your
    work need not make them do so.

  A compilation of a covered work with other separate and independent
works, which are not by their nature extensions of the covered work,
and which are not combined with it such as to form a larger program,
in or on a volume of a storage or distribution medium, is called an
"aggregate" if the compilation and its resulting copyright are not
used to limit the access or legal rights of the compilation's users
beyond what the individual works permit.  Inclusion of a covered work
in an aggregate does not cause this License to apply to the other
parts of the aggregate.

  6. Conveying Non-Source Forms.

  You may convey a covered work in object code form under the terms
of sections 4 and 5, provided that you also convey the
machine-readable Corresponding Source under the terms of this License,
in one of these ways:

    a) Convey the object code in, or embodied in, a physical product
    (including a physical distribution medium), accompanied by the
    Corresponding Source fixed on a durable physical medium
    customarily used for software interchange.

    b) Convey the object code in, or embodied in, a physical product
    (including a physical distribution medium), accompanied by a
    written offer, valid for at least three years and valid for as
    long as you offer spare parts or customer support for that product
    model, to give anyone who possesses the object code either (1) a
    copy of the Corresponding Source for all the software in the
    product that is covered by this License, on a durable physical
    medium customarily used for software interchange, for a price no
    more than your reasonable cost of physically performing this
    conveying of source, or (2) access to copy the
    Corresponding Source from a network server at no charge.

    c) Convey individual copies of the object code with a copy of the
    written offer to provide the Corresponding Source.  This
    alternative is allowed only occasionally and noncommercially, and
    only if you received the object code with such an offer, in accord
    with subsection 6b.

    d) Convey the object code by offering access from a designated
    place (gratis or for a charge), and offer equivalent access to the
    Corresponding Source in the same way through the same place at no
    further charge.  You need not require recipients to copy the
    Corresponding Source along with the object code.  If the place to
    copy the object code is a network server, the Corresponding Source
    may be on a different server (operated by you or a third party)
    that supports equivalent copying facilities, provided you maintain
    clear directions next to the object code saying where to find the
    Corresponding Source.  Regardless of what server hosts the
    Corresponding Source, you remain obligated to ensure that it is
    available for as long as needed to satisfy these requirements.

    e) Convey the object code using peer-to-peer transmission, provided
    you inform other peers where the object code and Corresponding
    Source of the work are being offered to the general public at no
    charge under subsection 6d.

  A separable portion of the object code, whose source code is excluded
from the Corresponding Source as a System Library, need not be
included in conveying the object code work.

  A "User Product" is either (1) a "consumer product", which means any
tangible personal property which is normally used for personal, family,
or household purposes, or (2) anything designed or sold for incorporation
into a dwelling.  In determining whether a product is a consumer product,
doubtful cases shall be resolved in favor of coverage.  For a particular
product received by a particular user, "normally used" refers to a
typical or common use of that class of product, regardless of the status
of the particular user or of the way in which the particular user
actually uses, or expects or is expected to use, the product.  A product
is a consumer product regardless of whether the product has substantial
commercial, industrial or non-consumer uses, unless such uses represent
the only significant mode of use of the product.

  "Installation Information" for a User Product means any methods,
procedures, authorization keys, or other information required to install
and execute modified versions of a covered work in that User Product from
a modified version of its Corresponding Source.  The information must
suffice to ensure that the continued functioning of the modified object
code is in no case prevented or interfered with solely because
modification has been made.

  If you convey an object code work under this section in, or with, or
specifically for use in, a User Product, and the conveying occurs as
part of a transaction in which the right of possession and use of the
User Product is transferred to the recipient in perpetuity or for a
fixed term (regardless of how the transaction is characterized), the
Corresponding Source conveyed under this section must be accompanied
by the Installation Information.  But this requirement does not apply
if neither you nor any third party retains the ability to install
modified object code on the User Product (for example, the work has
been installed in ROM).

  The requirement to provide Installation Information does not include a
requirement to continue to provide support service, warranty, or updates
for a work that has been modified or installed by the recipient, or for
the User Product in which it has been modified or installed.  Access to a
network may be denied when the modification itself materially and
adversely affects the operation of the network or violates the rules and
protocols for communication across the network.

  Corresponding Source conveyed, and Installation Information provided,
in accord with this section must be in a format that is publicly
documented (and with an implementation available to the public in
source code form), and must require no special password or key for
unpacking, reading or copying.

  7. Additional Terms.

  "Additional permissions" are terms that supplement the terms of this
License by making exceptions from one or more of its conditions.
Additional permissions that are applicable to the entire Program shall
be treated as though they were included in this License, to the extent
that they are valid under applicable law.  If additional permissions
apply only to part of the Program, that part may be used separately
under those permissions, but the entire Program remains governed by
this License without regard to the additional permissions.

  When you convey a copy of a covered work, you may at your option
remove any additional permissions from that copy, or from any part of
it.  (Additional permissions may be written to require their own
removal in certain cases when you modify the work.)  You may place
additional permissions on material, added by you to a covered work,
for which you have or can give appropriate copyright permission.

  Notwithstanding any other provision of this License, for material you
add to a covered work, you may (if authorized by the copyright holders of
that material) supplement the terms of this License with terms:

    a) Disclaiming warranty or limiting liability differently from the
    terms of sections 15 and 16 of this License; or

    b) Requiring preservation of specified reasonable legal notices or
    author attributions in that material or in the Appropriate Legal
    Notices displayed by works containing it; or

    c) Prohibiting misrepresentation of the origin of that material, or
    requiring that modified versions of such material be marked in
    reasonable ways as different from the original version; or

    d) Limiting the use for publicity purposes of names of licensors or
    authors of the material; or

    e) Declining to grant rights under trademark law for use of some
    trade names, trademarks, or service marks; or

    f) Requiring indemnification of licensors and authors of that
    material by anyone who conveys the material (or modified versions of
    it) with contractual assumptions of liability to the recipient, for
    any liability that these contractual assumptions directly impose on
    those licensors and authors.

  All other non-permissive additional terms are considered "further
restrictions" within the meaning of section 10.  If the Program as you
received it, or any part of it, contains a notice stating that it is
governed by this License along with a term that is a further
restriction, you may remove that term.  If a license document contains
a further restriction but permits relicensing or conveying under this
License, you may add to a covered work material governed by the terms
of that license document, provided that the further restriction does
not survive such relicensing or conveying.

  If you add terms to a covered work in accord with this section, you
must place, in the relevant source files, a statement of the
additional terms that apply to those files, or a notice indicating
where to find the applicable terms.

  Additional terms, permissive or non-permissive, may be stated in the
form of a separately written license, or stated as exceptions;
the above requirements apply either way.

  8. Termination.

  You may not propagate or modify a covered work except as expressly
provided under this License.  Any attempt otherwise to propagate or
modify it is void, and will automatically terminate your rights under
this License (including any patent licenses granted under the third
paragraph of section 11).

  However, if you cease all violation of this License, then your
license from a particular copyright holder is reinstated (a)
provisionally, unless and until the copyright holder explicitly and
finally terminates your license, and (b) permanently, if the copyright
holder fails to notify you of the violation by some reasonable means
prior to 60 days after the cessation.

  Moreover, your license from a particular copyright holder is
reinstated permanently if the copyright holder notifies you of the
violation by some reasonable means, this is the first time you have
received notice of violation of this License (for any work) from that
copyright holder, and you cure the violation prior to 30 days after
your receipt of the notice.

  Termination of your rights under this section does not terminate the
licenses of parties who have received copies or rights from you under
this License.  If your rights have been terminated and not permanently
reinstated, you do not qualify to receive new licenses for the same
material under section 10.

  9. Acceptance Not Required for Having Copies.

  You are not required to accept this License in order to receive or
run a copy of the Program.  Ancillary propagation of a covered work
occurring solely as a consequence of using peer-to-peer transmission
to receive a copy likewise does not require acceptance.  However,
nothing other than this License grants you permission to propagate or
modify any covered work.  These actions infringe copyright if you do
not accept this License.  Therefore, by modifying or propagating a
covered work, you indicate your acceptance of this License to do so.

  10. Automatic Licensing of Downstream Recipients.

  Each time you convey a covered work, the recipient automatically
receives a license from the original licensors, to run, modify and
propagate that work, subject to this License.  You are not responsible
for enforcing compliance by third parties with this License.

  An "entity transaction" is a transaction transferring control of an
organization, or substantially all assets of one, or subdividing an
organization, or merging organizations.  If propagation of a covered
work results from an entity transaction, each party to that
transaction who receives a copy of the work also receives whatever
licenses to the work the party's predecessor in interest had or could
give under the previous paragraph, plus a right to possession of the
Corresponding Source of the work from the predecessor in interest, if
the predecessor has it or can get it with reasonable efforts.

  You may not impose any further restrictions on the exercise of the
rights granted or affirmed under this License.  For example, you may
not impose a license fee, royalty, or other charge for exercise of
rights granted under this License, and you may not initiate litigation
(including a cross-claim or counterclaim in a lawsuit) alleging that
any patent claim is infringed by making, using, selling, offering for
sale, or importing the Program or any portion of it.

  11. Patents.

  A "contributor" is a copyright holder who authorizes use under this
License of the Program or a work on which the Program is based.  The
work thus licensed is called the contributor's "contributor version".

  A contributor's "essential patent claims" are all patent claims
owned or controlled by the contributor, whether already acquired or
hereafter acquired, that would be infringed by some manner, permitted
by this License, of making, using, or selling its contributor version,
but do not include claims that would be infringed only as a
consequence of further modification of the contributor version.  For
purposes of this definition, "control" includes the right to grant
patent sublicenses in a manner consistent with the requirements of
this License.

  Each contributor grants you a non-exclusive, worldwide, royalty-free
patent license under the contributor's essential patent claims, to
make, use, sell, offer for sale, import and otherwise run, modify and
propagate the contents of its contributor version.

  In the following three paragraphs, a "patent license" is any express
agreement or commitment, however denominated, not to enforce a patent
(such as an express permission to practice a patent or covenant not to
sue for patent infringement).  To "grant" such a patent license to a
party means to make such an agreement or commitment not to enforce a
patent against the party.

  If you convey a covered work, knowingly relying on a patent license,
and the Corresponding Source of the work is not available for anyone
to copy, free of charge and under the terms of this License, through a
publicly available network server or other readily accessible means,
then you must either (1) cause the Corresponding Source to be so
available, or (2) arrange to deprive yourself of the benefit of the
patent license for this particular work, or (3) arrange, in a manner
consistent with the requirements of this License, to extend the patent
license to downstream recipients.  "Knowingly relying" means you have
actual knowledge that, but for the patent license, your conveying the
covered work in a country, or your recipient's use of the covered work
in a country, would infringe one or more identifiable patents in that
country that you have reason to believe are valid.

  If, pursuant to or in connection with a single transaction or
arrangement, you convey, or propagate by procuring conveyance of, a
covered work, and grant a patent license to some of the parties
receiving the covered work authorizing them to use, propagate, modify
or convey a specific copy of the covered work, then the patent license
you grant is automatically extended to all recipients of the covered
work and works based on it.

  A patent license is "discriminatory" if it does not include within
the scope of its coverage, prohibits the exercise of, or is
conditioned on the non-exercise of one or more of the rights that are
specifically granted under this License.  You may not convey a covered
work if you are a party to an arrangement with a third party that is
in the business of distributing software, under which you make payment
to the third party based on the extent of your activity of conveying
the work, and under which the third party grants, to any of the
parties who would receive the covered work from you, a discriminatory
patent license (a) in connection with copies of the covered work
conveyed by you (or copies made from those copies), or (b) primarily
for and in connection with specific products or compilations that
contain the covered work, unless you entered into that arrangement,
or that patent license was granted, prior to 28 March 2007.

  Nothing in this License shall be construed as excluding or limiting
any implied license or other defenses to infringement that may
otherwise be available to you under applicable patent law.

  12. No Surrender of Others' Freedom.

  If conditions are imposed on you (whether by court order, agreement or
otherwise) that contradict the conditions of this License, they do not
excuse you from the conditions of this License.  If you cannot convey a
covered work so as to satisfy simultaneously your obligations under this
License and any other pertinent obligations, then as a consequence you may
not convey it at all.  For example, if you agree to terms that obligate you
to collect a royalty for further conveying from those to whom you convey
the Program, the only way you could satisfy both those terms and this
License would be to refrain entirely from conveying the Program.

  13. Use with the GNU Affero General Public License.

  Notwithstanding any other provision of this License, you have
permission to link or combine any covered work with a work licensed
under version 3 of the GNU Affero General Public License into a single
combined work, and to convey the resulting work.  The terms of this
License will continue to apply to the part which is the covered work,
but the special requirements of the GNU Affero General Public License,
section 13, concerning interaction through a network will apply to the
combination as such.

  14. Revised Versions of this License.

  The Free Software Foundation may publish revised and/or new versions of
the GNU General Public License from time to time.  Such new versions will
be similar in spirit to the present version, but may differ in detail to
address new problems or concerns.

  Each version is given a distinguishing version number.  If the
Program specifies that a certain numbered version of the GNU General
Public License "or any later version" applies to it, you have the
option of following the terms and conditions either of that numbered
version or of any later version published by the Free Software
Foundation.  If the Program does not specify a version number of the
GNU General Public License, you may choose any version ever published
by the Free Software Foundation.

  If the Program specifies that a proxy can decide which future
versions of the GNU General Public License can be used, that proxy's
public statement of acceptance of a version permanently authorizes you
to choose that version for the Program.

  Later license versions may give you additional or different
permissions.  However, no additional obligations are imposed on any
author or copyright holder as a result of your choosing to follow a
later version.

  15. Disclaimer of Warranty.

  THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY
APPLICABLE LAW.  EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT
HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY
OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE.  THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM
IS WITH YOU.  SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF
ALL NECESSARY SERVICING, REPAIR OR CORRECTION.

  16. Limitation of Liability.

  IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MODIFIES AND/OR CONVEYS
THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY
GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE
USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF
DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD
PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS),
EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

  17. Interpretation of Sections 15 and 16.

  If the disclaimer of warranty and limitation of liability provided
above cannot be given local legal effect according to their terms,
reviewing courts shall apply local law that most closely approximates
an absolute waiver of all civil liability in connection with the
Program, unless a warranty or assumption of liability accompanies a
copy of the Program in return for a fee.

                     END OF TERMS AND CONDITIONS

            How to Apply These Terms to Your New Programs

  If you develop a new program, and you want it to be of the greatest
possible use to the public, the best way to achieve this is to make it
free software which everyone can redistribute and change under these terms.

  To do so, attach the following notices to the program.  It is safest
to attach them to the start of each source file to most effectively
state the exclusion of warranty; and each file should have at least
the "copyright" line and a pointer to where the full notice is found.

    <one line to give the program's name and a brief idea of what it does.>
    Copyright (C) <year>  <name of author>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

Also add information on how to contact you by electronic and paper mail.

  If the program does terminal interaction, make it output a short
notice like this when it starts in an interactive mode:

    <program>  Copyright (C) <year>  <name of author>
    This program comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
    This is free software, and you are welcome to redistribute it
    under certain conditions; type `show c' for details.

The hypothetical commands `show w' and `show c' should show the appropriate
parts of the General Public License.  Of course, your program's commands
might be different; for a GUI interface, you would use an "about box".

  You should also get your employer (if you work as a programmer) or school,
if any, to sign a "copyright disclaimer" for the program, if necessary.
For more information on this, and how to apply and follow the GNU GPL, see
<https://www.gnu.org/licenses/>.

  The GNU General Public License does not permit incorporating your program
into proprietary programs.  If your program is a subroutine library, you
may consider it more useful to permit linking proprietary applications with
the library.  If this is what you want to do, use the GNU Lesser General
Public License instead of this License.  But first, please read
<https://www.gnu.org/licenses/why-not-lgpl.html>.

____cpack__here_doc____
    echo
    echo "Do you accept the license? [yN]: "
    read line leftover
    case ${line} in
      y* | Y*)
        cpack_license_accepted=TRUE;;
      *)
        echo "License not accepted. Exiting ..."
        exit 1;;
    esac
  fi

  if [ "x${cpack_include_subdir}x" = "xx" ]
  then
    echo "By default the LIBLCG will be installed in:"
    echo "  \"${toplevel}/LIBLCG-1.0.0-Darwin\""
    echo "Do you want to include the subdirectory LIBLCG-1.0.0-Darwin?"
    echo "Saying no will install in: \"${toplevel}\" [Yn]: "
    read line leftover
    cpack_include_subdir=TRUE
    case ${line} in
      n* | N*)
        cpack_include_subdir=FALSE
    esac
  fi
fi

if [ "x${cpack_include_subdir}x" = "xTRUEx" ]
then
  toplevel="${toplevel}/LIBLCG-1.0.0-Darwin"
  mkdir -p "${toplevel}"
fi
echo
echo "Using target directory: ${toplevel}"
echo "Extracting, please wait..."
echo ""

# take the archive portion of this file and pipe it to tar
# the NUMERIC parameter in this command should be one more
# than the number of lines in this header file
# there are tails which don't understand the "-n" argument, e.g. on SunOS
# OTOH there are tails which complain when not using the "-n" argument (e.g. GNU)
# so at first try to tail some file to see if tail fails if used with "-n"
# if so, don't use "-n"
use_new_tail_syntax="-n"
tail $use_new_tail_syntax +1 "$0" > /dev/null 2> /dev/null || use_new_tail_syntax=""

extractor="pax -r"
command -v pax > /dev/null 2> /dev/null || extractor="tar xf -"

tail $use_new_tail_syntax +821 "$0" | gunzip | (cd "${toplevel}" && ${extractor}) || cpack_echo_exit "Problem unpacking the LIBLCG-1.0.0-Darwin"

echo "Unpacking finished successfully"

exit 0
#-----------------------------------------------------------
#      Start of TAR.GZ file
#-----------------------------------------------------------;

‹ hææ^ í}|[Õ‘÷•‰‚­ğªic¸ NìØ‰Ã#Ø‰•ÈÅNDœ@BMY’cYz$›lMS»Æ‹KÙŸÛå×5}º-İº»…õ²ek(K\0­›Ò]ï·¡¸]
Ê ^Z¶BüÍœ9÷¡ûdÇ@÷[ßV9wÎ½3çœ93óŸ+™;ş '÷úÖàa³ÙÖWTˆ¬]G­­¬œZ~ˆ¥k×­/­X·¶´Â&ÚJ×®-+ÄŠrRÒÆÜ˜Ê=-îàşC~Óûà¶æærø:äöÈáçûğì/iù€Æ }¬+/7ÛÿÒò²Òu´ÿååë×–•ŠØU¾^mĞ|’ÿåû¿fÕ¬5À·X\%Â±ùÚkÅ€¿)âCÍpô¹#¢'üt|¿;æ÷GÜ^¿/+û‘es(|(âßß‹=+Å2[é†ëÊleÄ=~ñÜ±˜oE4Zå÷Bqo‰'ÔºY«‘±FÅˆ/ê‹ğy%©N_¤8ü¡ èŠ-¾ˆ¯éŒù¼«ÅæˆÏ‡“ó´¸#û}«ÅXHt‰a_$
¡¦˜ÛôÃĞn˜wøÊƒ›c- )jtG|p¿WtG£!å½!O¼VåáÍş€/*ÇZ|â•œãÊ•l¯Ï@ş ˆ—¥«âA¬%áBb¿Å¬Éq&Òå€¿ÕÏAvZ=ÊÑñ(,'¼ZlyıÍØúØúÂñ¦€?Ú²ZôúQzS<Qìôø‚È«YŠˆQ_€M„øalÑÊÙm8P•ãêŠbÏÁ–PkòzülVÍñHö16oÔÇÆı´ÏÃäh¡ƒ¸F°¯—½ïâN¸în
ğ±e‘•C1˜5Mw$¬ì4¿mqƒa4ù¸ú`p¥a¯´²N|8ó»b8aãjW,YÓN‡]lØ¾eçíÕ;ìbmƒèÜ±ı¶Ú{xeuĞW®o¯İéØ¾k§wì¨Ş¶s¸}‹X½mxKí¶šÕ¢}·s‡½¡AÜ¾¥ÕÖ;ëjíĞ]»msİ®šÚm[ÅMÀºmûN±®¶¾v'Èİ¹É¥ÕÚP^½}ÇfÕ›jëjwîY²¶ÔîÜ†’·lß!V‹Îê;k7ïª«Ş!:wípno°Ã$j@ò¶Úm[vÀ@özû¶%00ô‰öÛ€Õuu8ó¨]°Œ8Qqóvçµ[;EÇöº;tn²Ãüª7ÕÙi4XİæºêÚúÕbMu}õV;ãÚ‚Ø"ñNš¦x»Ã½8j5üóÎÚíÛp=›·oÛ¹ÈÕ°Ü;eîÛkì«Åêµ¨™-;¶×³•¢vi;“¬Ûì$5Ÿ¼ApÒ»ì²L±Æ^]â`·¶i77y¶ÇšÅ‹—û›ƒ^_³èªÛ¼ÕåX¼Î!äIäb«š"~¸‰ÕbÔßøDv+³xÉğš!7xÆ¡0:4]%"Š°»£‡Ği<}R iÇâd¨k#NÅ×ö‰€á.&ğÃiì„»™Å·ú ¶ 7ÁĞP<àEß‰ø<¡ıAÿ=à=9q$ø"Å+aØ ‹Q4°/oU]w!½øÏ/ÂQ±¯ş|Ğ¼¼fñ"TÖæ­«'ÏÃLAœIÆŒŞ§öİ bİäÏh¼MµÀŞ˜'á,¼»#1#1e«1Ş)§;â!n%;1%JQ>!·$Ìê½¨w·ù[!æùA«/ZÂ‚-X;ˆ‰Ü8Æp±Ôf+aD·÷Óñ+ÍGdÁ>Â …˜ÒdÄ<Æ›˜Î"TçînsÉó‰‚äÙÚÃQ 5ÄrˆˆgAˆñ1Ğ#S"L;iF^ü·<0ÊFv{<ñˆÛsˆ´°Åïiaı0›xŒg0É&Ä¡xĞ[B+ªA í=\AL"h;
|Añğáı‡¯9|¸éğañÆ›DŸ#Lñpu›x¸)©§Î¤šjb5ŠÌ<|¸$z}€c|úö¸'à‡”!(×•­€‹´2ä;ÿc2Õ7×•²ŒvÌFšnªïºu\ûrŒ®«•{Øè”r@b¦5˜LŒf˜4ld:Õõ5+A‰±ƒ>T¤àóáøh§8Áp$wG¹’í­Ù€‘hŸpZ™läMî(ø/ŠÇ}8a†^•d˜¿[v?J
ğ>ÑÏÓ¹îˆß±S;å$‘¸OrÏ¦P(€ËvábÕšÙAnœ´ÇlÔş	ÇşPìÎpKø>ğ‘”}àÂ%ï‡APØ©L“Ûs€ Øf³Ûã#q<ñ )†ëÛ‹a vß-n[µü²¿6qEõ
±fâüßİ"X$$O@n²V´­ÀPÂ§Š¹—£aÆƒ!z´0U‚Ã¹cnĞl¤CJ0Í³Yn›¨õÒ¼"R¬kâIbªVq9•…VkVÖ–ÄtEÒˆ©Ï€£y”L»5¸&:(x5ñX[¬B~¯X¼
ènÃ•¹Â±ÈÊbì^%ksp8Uàw•Ø¶ZMáj\ÕmÒ} i^+a§â¿Én·† w ûR6{?ØN”2c)b±KJ¨»úĞáéL·½Ü‹b«j‹Q2Dåƒd‡£šû¥X¯½Ÿ|G ’×')A#M½í(-Ê·™¥Mf¹K3aeH‘øòGÄƒÙ0åÅd;|‘ËÕBğ€ŒÓ6„Â1SäX¸ÃÃ‡$OşmpCÁëîA™´~Ë’÷ØPx’ñâüÈv%-eh½­º>y{ÔWPu«‰õ¦­î¹k¥qšSò¸º´†"‡˜±¹UC†CÌüY^!=—Ñv}Ê¼T”äÔ’™¯;q’™"Lã8¸PÎÁî[89»U©O!y‚ëÅªš¬§åC‡¤1àQåÒª\?y~²J‘Ñh–45˜°ˆÏW¬8&s"kÓåi²ã³4)	¨¢²©ïŠbTô öc6ÀğSr~´õı€Ÿ§œEWp“•bGêÌUÔnPµÉD•a×ğ„íRÆ.N§ü2Ï×¸ƒü«›T1n~ÑÄxÕhíüğ@ØFaÃ‰€@ê Ö¨ôJ0˜(76 iƒ,¿Ó"Ce—\ÀZŒV*ÍËD'Õ°3­M~“‡-š¦~’ªuW7‡åp%#–liÒ“Õ<İPKt¦•¨À´8ŒCµøì¡[~ ÔGÇ³IÅ³}wå?à“ò$)ÖĞ×œÑCÑ˜¯U·£´#é)„CèiFĞMGuª<bögêejqç‚ùÈKÏcê¼Úçg+0`¬ CÀã"†Å&•M±/åVlÛUWG7í„š`säËº‰óï  ‚RÉ>Yˆ`q6¢ë›cœ‹óot£8U›¯şRBÚ²bŞPf
Î‰_kªœ›·r½¯4×käò1w,.?î'Û‚Ş¬Úälı²M5Ê£/­Né«ÄMF°½x‘	ÂkÓÍ×?ªí¹IR®Á˜N¸Œ˜‰@`Zîõ6‹kÖĞ×gõ¯!ÿû€¿éıí™ÿş[V¿ÿÍÿşûÁ¸ÿğÁŸİÔ©ÿ]W{¼ÿå¶Šòùß?ŒãŠİOËÆÅËK×”ÙTĞWZ±¡¬tƒ­bıZQ¬°•B].¥½+*¥»÷-v¹JöÔ×Ø·ˆÛwì´× \'—ß™%›xÛÀÛoğö	Şşo—Z¨­ãíçxûW¼‡Öåº£Ôhò{öÃ†4•9·ppŞâuzıvçƒ«¡ÔåuŞR)¡—ßoo(ÃNÃz»Ê%ÈÏu~¥ƒl†"K+4@(±6)%gÃ”•?·À‹xÿì–S—£³eÏvÔJé1ÔéErƒ¼)³'&öW¾Îfleë*Ö–qûÃàå	‡KB*»şÙ»oœ](–l8³ràã@B¤ë—Âg$ËÜ/lÜ€[²“é…ü“Çïs¹b¾¶˜Âçrí´ïŞ©—gİªÈÃaûÀØÄÚÕ÷¹\,e2•'r9|Bç'!×|(%MäUqy“j@^¶Š_«"—+Àº•ÆòlµÔJúé«K–—c&¯tñü¸<+§ê’eäëäùZÀ*Á±Œççäò&P;Äç7°G6B{lQ²<¶øëZ(b´^§tà¾¦:\àş*qÉ³¤WŸBß“¿XîÏâı}ŸÌ£{ayl}rl¾Š«D »é±ËÑõ[ÇÑ×Å®#¯wÛ_wô9˜¦£À±aìàyÔ÷ÔDöéÜŞîè:Î[û”£Û>õ“sVG×‘)ÇÑ#SBìBj–àuùşãö)l{9Ş—^¼goX™¼U°´*;­²ê.öbÏLD×‘3GœÉ*8ö¸ÈÎ8Eg–‚cÒÙ¿„³{œYxfzú38à¤àşAo·ıL.šâÑ©…Ÿû[èèvô\ÔÁfÛ“{Ş‘“‹ï¹}Áa›(¸\¨†sp1†…ğA3Âç |ÚiT!î(ç´[:Ù-l—N¶H'7I'åÒÉµÒÉ•ÒÉ¥Ò‰U:YÈOî”6 
tšptÅ']»Æ]õc5]öÑº®úán{áÑ©œƒ“–·Tµ¼\iy¸æ+¸-İ€t¯´ß§«ÔÄZ5qš¸TM,Q½ÒùûT<¬Dâ‡Àœ.«ë¶wut×9ºaİ°n{b:.NÇ­uİ»¦ê»ªîB{ª>á8úŒU²¤{_ßgAñOœvt=6Ìš‡†XÓ3MMWÇ£ĞÔuõôcçÑ'±b‹İx&«ÒÑFüĞŞÓíÌƒÓq:ÅŞ	vZUèèêHÀéÑ'Q¢ğ™ÅC˜ı©ŸwrvC_ö=‘‹6kíA!Í¿n.XóTdñP6^ûr.óˆaîC¼Ä¶›MVq³amÇ¶c°»çQ6½]ƒ°$\x]wiãYG÷kõ4¨Ô>SÏ›ÆÛìCp*Ğé0œNÁ­\f‡•uw2îIlzXó8Ø4â³›ğŒM ×¾iŸ”NÇígò¯˜Ô‚‰Dk»è_HÕ4„eT”g~	4¸ç)hë'ß*ØıFs3¬ÀPˆÔ/KHHGíg,§öÂBÛ_!ãÎm°¿RĞó@IÁã¸ÛÇ†Y-ÊúF´Ë:3›Š´İ®1›Ôïşü|RŞíO.4Ÿºµ~DšöNûô½o¬b»×ìpm/]£fF]Ó}än=Ü”áj÷cd=xxQ³£ 8L¦ñóá‚‡†ÇÀ”aôSÙÙÌl;Èl×ØG
>{ú™‰zPIê“8Ğê^Ø“úWº¢A;hĞäGº~îèzÚxÀ¿ÌbÚÍÅ¸ Üjyxô6r îR›¹}HgãÒFë6Ê¡Uğ‰Íjlf\Rş8Sşwåcç ’ğÏÒ*r&t±JÅÅlŠ‹O+.æ £ Õ!N3­acêbºíĞzÌâ1æ—À.KºgşÊGD<u1l[ÚW%í¥×^¦7&ioLÑŞj/ıœ\Š¤É¥ûåíV”çT)¯…ÔåL¥®£öW,§Vœ‘Dñ8ÉdÉçƒÒ¹ìü€D¹ˆD¹Ìàdp$pi#p	¸´¸ì#pi$pq¸8epqêÁ¥]—N\zpécàÒ¨—Ûà,Û“ÀeÓ—Np¹f9¸@;@«nÔ‚LrÇ¶cPÛ1ĞİÓHî8 km!ÔiÓ¢Î ¬iğ¬¼•j˜ 2Ìî}äı=úSAw1‚ef%cŠè:E%«F™ ¹Ã³‡°F33#ZG0/Z¼1*—2‚°v	Â&ÂzÓAXãG
aFVAX#AX»adb=á´v5‡°N#ËËfV l’…$a4hš<`*û‡°I	ÂªáeûaŠÏØuca†AxĞÄö2€°IÂúåĞ+R¼E-TĞÌªä<% óÜ±PÎÉÕŠ	ØZ2ÏuËÔ[‹9°)—€íŠÔÀf¬ÓLıÙØ&±³O6ÌdL• HÊs°ÙÒÛÒ3Ò>È`6dl´™Èµ§¹I¹J9\1œH ·Œ@ÎJ g•AÎª¹*ä
È9ÛÍ@n™äî_ˆ³¬J¹¶…rk\hnĞöó¶·½¼í$m,Ób]rÇ ¶c@ÛÑ¯íèÓvôj;:»{–‘ï÷ƒÚŠ	/+µxÙê¡ÌÀŞ§<ü¡W¶•M(¬ `ó?6R¥"ùß>ò¿}ŸÚ7PØ‘mZoÍ‘J¹d€xÌC¾i¬ËÎ)7OÃÓß•‘°JBÂr”Ï~à!ÍÀÃÒÀÃ40€­Ó lÇu#êÀv(-Øe¶C*°ÕÄ{¶Ë8ØK`;.lSí2[r\¸ÚıÙg--Øş‚ƒ­ƒƒí¸l'°µ)`;¬</Ò 4hò€©À¶‰´'=/:4`{c6‚­âpö·fEÆ¦ÑŸ¡Mj2åyq;Û‘lG8&Ew:¤,ØŞ«äÉ}<Oæ! _åá#$ÉI«îÔ­ZÃ¤2‡„2Ú„ZÆUOQh!H ¬›ô3‚öe†Ğ^líÊ%hw§†ös‹*)ŸY;Ú¦É‘äÇVŞ#§O½JúÔ§¤Oú¯Ş$Åìiaÿª÷tÏ³†POû(Ÿ÷©Î{UçJjP•25°e±Ô`ê}–L²æ¡kz&Şg©ÁÉ÷Yj0ö>K°¡Ô Ï4© ¤yJj`URƒB– D95øbÎRHJ:ò(5È3Hüy™§Ğ¶“pÈ$ÀOîè×vôi;zµÚöîì ×ìí Á;I±ª M¨J‰•ŠoÚ”d ˜ù&ßA9VÇÄûô}ù¦8cØGazØgRa_¹43ØgétÀÄAû3…}A‚ıÅ”Î~`íƒÔ 4ğ ûÖt°ÏFÔÁş@ZØÈöÒÀ>®ƒıÉ÷ØgÖØÃ’Á>eŞ”ösè×<#Ø-‡Á>Å`P}´ƒM0ì?˜C°?˜ûyØoÍA ä^Ö.¤s1CØ76öm2%ìK !CE©»]ÊÑ	ƒw+ÎíT9w˜ÜÙ™ñ•°ÂßxÁC8­!]2Œ¼==‚şë­^“åwš&Ä™JèÕH’$±/¶¼fY²ˆ3îs†¹ûÏ&ë´OQd¯;;UŠ¤Œªƒ‹«è‹Œ2fº&¡D@óKÌq9ƒQ¯iDYÃ°’)v1¨ZOÁ3	ócs}Ò#¾{ù:ö¨Ò¥]ºÔÂ×*hösJñ‰IeÿÊÚ'TkÏ£œi"ÕÚYÎôÚ;ÿìr#š‘”'	)ó¤*Ê“È¾#0~hœò¤1Ê“F)O¦<iXÎ“†õyË³(Ošz_Î“%OÊcyÒ¨:Ozï<œ%r*yÒkçQ„B´yÒóçæP9xí{çe;93 %j³¦ä>mG¯¶£SÛÑ®é`ƒu÷ŒRÈëıS&•ĞfRJÎÔËs&nX¢’T2Ãb#ğ\‹å­˜¼“‹YgœIfRcæ™”rif™Ô¨¡/›=¬öešI¡	±Ljë"e…³XD¤äLJH—IfRıi3©şŒ2©ş4™Ô¨Q&5¡Ê¤F)“"·e™%{DJIÕĞ£L¹¨&“Z‘Ç2©	%“P2)´ƒM0U&õúZÕ>”IñáåLê»ø…,÷²‡ÚøÓ­ÎË“)¶W·hœÉÈÌ25ùÔ·“ó)m.@™É§ä‰#‰Cñò*•—ïS¾w2õk•IşÒbò8al’íiM²=#“lW™¤æÑ#É$%“Li’ƒ31Éïç&›ä`Ág&$'D£,kü ÿ»qÓ8§NûØî™²²Õ¦œjP}ºõ›J·Nm‚1Éº–£X7bˆ½İÔ´MÒæQÓ´¹Ódõí§Íf´‰wÚ´™'`rÚÕ{6Ùu:giW€²Må,”X“~å§‘p¦ió¨aÚ<Û}üx¶:m–Ö4¤¬aPÉ u_ Òr†3øÕ0m>7¨Õ¦Í<8ØÇ\Èòã¤P+¥ÌìÏaTO¹Œ.¸o‰Å@ÉÍS{š÷-QM"¨5ËÀ¹ïïUİÏ&şÀ‡ Å>÷ò=V?RìNz¤8õ°@‘*S¼w77œÉ³ÉÎ‘HÂ‘	ÅÆ[SÙÒTß‚³Çoÿ·Ä?»GyRÒ“OĞŸD¾îttb_³Gû$?‡'{‚ŸÃƒ…}Ï»«Ä.ûIêÅl{¬(Ø®úGÏ®áÚ®ŸÔvı#‚ÂZİäµ!8>ISî‚Mî¶t=¥İíIcG·™XÇëo4Šÿüš^VúÕ$™ë†ú3÷ßÅwÁrğ'ó•”“ïØ—IªÛªÃ¿ÌÀ¿ì«YúÍI‘	~nåÊàŠÇóîªâ.û‹Ô‹Šé
9£¥Uä¿ÑR†H‘ÃzE¤Ts'ıßÆ˜£)ÌÚX`"•Àq•@YÅ·’Ša¡øóD’ŠWêT,['ªØ*©X²É„b‰Ü<Á<%›ÃL£ÊØŸ3CdjÓ«1åê&Rª¤Q½êÃß€¹À|@ÅêÇ?k²Zn6ºµ²¾¢¬z¼¨Œ×z(åZÇMüerËüñ2?g¾Ì´!‡/T>/J’YÈù¾&ä<›©a§
Fz'I â¤7ÄÁš‡™í:ƒºúĞl’@OU1W‹\a}\©ãü•:ÆÏQ©#xŞ]UÙe†zéoZ€B¥Â¬Ò*u¹…¾$¥êmÉì÷Ó”ág(EøK¹Ö<X¯8–Ì¤Ù@ãªm—CY.m#(¿5LÚÆ—Îş‰…²ÔÑÊdKú a(“±‘›©„Œ¢
UÈh•‘ëcŒPÒÖeUP}F™>†Pë™¢ä édHïûÃi¬*¥Aí:ãğœ Gÿ%]Üò)riVª  cœP1Ê‚£$,¸Oƒ’çˆğ<NÎIF%g–ˆœÒ$"f¨2–ÊqS¥u³‹×šä6ó¤äÿ‡4/¥Sgæ™%ÓÆÛ5®Ïf˜æ}t<•NÅf¤†Æ*Nˆ­f[Â¡OgjÛÌ÷ Ï|x”ş°Œü	Íè¢ôÈSPÅÓÜux"U Nâ ¹·¤~\)TcüÜç¶ïÍ¥Í<9eÆ4¡÷d†÷úDÕï“=XÖÃiAßœm˜”tÔ\PŒÉİ®DÊ|}/U,•v¯‰¹ìùS6—ÄşÃ\Î1ä5Ão‰Sé(Aú0ĞO«•Õab*wÎGçùè<ç£ó|tşÓÎ‚æğò¶çÇúÿøìàFAC'¿j<âs{Zè¼Rå‹ºgª—¼ŠÑX(V^4,¿^zo:¾>Wz¥¨"ÏÇcÊûĞEVæ* sğ’^/2AP<‹–»‚wCƒüÄ‚"Gz»º"Éƒ>˜©ÿ€zş­Æ•H’ïf/QVJWhÄ°ËM1ƒÛLÆóG%«å…Õ¯yå%<îàŠ–À—•òw“‡3­QC£‡¼¾ o4Sí6÷¶ğ£]:¹ˆ·–{v–6«Åºda^/øE9ô-ƒÏ½RµÄƒN“o½/+_cuş‚œ¡&~ùğõRœ¯Ô”oµï~ø„9ßfS¾:¾gàSÉùÎ·˜ñåY´|ì'aÎ÷®éxoëÆ+‡[ğ¯_ñ¸sßîZ¾ ÜÒËù~kÊ7¡ãûÜ²›ó}"ÏŒï’<-ßI¸Eä|Å‹Ìø–/Òò]”áğ}âûü3¾%Z¾:àä|7˜îÃ:İ>¾6Îç1åÛ«ãû!ğUq¾7M÷ï”nÿş |yœï5S¾ßèøVÃ•±3Ä·Æt«tóôÂ•>ÎwÜ”ïißÃpeß™™¯ïE¸RÌùZMÇkÑ·$G&ß#¾½¦|{t|5À7ôŞÌ÷ï0ğµs¾c¦|ŸÑñı ÿ{ÎWcÊw³ïuà³¾7s¿*WÆß%¾
Óñlºñ¯ÿİ™÷àká|¥¦ã­Ö7
|¶wg®—ˆ8SïÌ|7ßğ;3×Kø:g1Ş£Àç|gfzY¼•½îº÷·Âhï€Öí¿Û©ÌNı;ìÔÿrõŸ¨¡şkk¨ÿÛ›©ÿ‘ÍÔ¿|3õn¢ş¯n¢şSÕÔ¨¦~W5õÿ°Šúo¨¢ş²*êÿÁÍÔ_}3õ—ßLı=©ÉFêÏŞHı7Qÿ7QîMÔËÔÿÓ¨ÿ©¨ÿ'×Sÿ'¯§ş›®§şæÔÿZ%õÿŸJêÏ«¤ş®õÔx=õ}õ/[Gı®£ş‡*¨¿¤‚ú¯¨ ş³k©ÿZê¿c-õ«Œú+Ë¨Mõ?^Jı·–R¿£”úŸ³Q¿ÇFı·Ù¨ÿ3k¨	ìÿ}	õ?_ÂŞÑY´®„®ÿíu·¡ıŞ>ÈÛÏñöÏxâíĞÂĞ×í‚öJÓu-ÉË¿–ú]ËŞ9XT¿ŠhÇ*önÔ¢?_A÷]°‚úÏ‡ör O_Eı×/§ş
h/ú; üj ¿ÄÛ.Ş¶ñv?ooãíıW0s.ºê
šg!o—ğVàíDj¼ı…Hãş'	ÿÿ·Ë‰>q9ËïŠ.áôRh?ôŠˆ~ÚıÈ'hş“—RÿéKÙ»l‹¼—Ò¼x»‰·¥¼y[À[o!ÍÿÌÇh^“¼}…·ã¼åí0oÀÛ¿ùÿ¥±÷Œí¼„èíĞBWÑ=-t}ûBš÷;K©ÿĞÂ¥¢¦¥4Ÿ[y[ÅÛ5¼½Œ·çóöŒ•ÚZz!lÑ¯h>¿äíOxû$o
h¼¯°ÜºèP>Ñ1haJE7-¡yá‹Q±ÿ½Å‚pĞ‹9´0tQÙb÷
ŞZy;½ˆës×g×'o_áíÏòHŞsyì]¶Eı‰şkhajE÷äÒ<nÊ¡şJhÏú‡Ù$ÿ;¼ıoÒKu‹Â;]‹û-˜~ÑíYì®EŸÌB#y¼ßÆï[íJ”kaï.ú{ŒÎ¸?önØ¢G,ì}°E}ĞÂ’Š°°wùİgaï‡-:-„ı¢ç¿ËÂŞÇ[ÔdaïÑ-Âl†(úºÀŞI[t?o={Wíuvø\w-aÈuƒ \p/¶àZùmœÆ\(¿ŠÓØ‚Ëäçq[p‘ü±\¢±?Îïã4¶à2ùû8-øW~1§±EWšÌ![ğ¯ü!Nc®’ßÎilÁÎóœÆöctœÆì<<›hlÁ¾óû9-Ø_~§±E—°q[°»ü©,¢±»Ëæ4¶`7ùœÆì&ßÉilÁ^ò9]Hv?a![°‡üNcv‘æ4¶Z+9íJ4INc{Ğ#ÑØbˆíå4¶Å@ïæ4¶`÷ù"§±»ÍïÀì Kyõõ`Tù9Ê{£_@?ÈVŞKı©¢[8]–Mô§û²ˆ>Íé/pš½|^Nsú~NßÊéNN‡9}ŒÓ}œŞ¸èaNÿœÏïi¾xtóüuD¯Ãùå*ï­Ş·€®/àU6NåíçÅ:9ÿíüÁüüşeDßßº–èöl¢ËyqŒÍœÿJz}¶ğ¯¹D?°hçƒ¿¯ûÎï¼è¥yD¿x_xÑ×qyğo,ş…óo½™è‡³ˆ®®âûÅåEøoryo"ú —7È¿P(àóûmÑ¯ry/Û‰ş1Ş¿@yo÷&´{ğWÀ¿ .rO8¦9ı4ïû§ã×-œpzÄBôù‹ÎwpúlÑ=œ¾”?¯Or~¾<!‹ÏçRÂS!$$¿¯ûıIı%}™†~PCÿTC§-+àu;¡İº½Şé
„BaW0lC±PĞïqíû½>¯+ˆ¯°OsûÊM}“/Œ¡ƒn‡©«„ñÙĞH±a·bW à˜•DĞ–bpyÚÜ®XK$tĞÕäöºXé;˜ßAWÀÜk1(<ğÔnøh
*Ì¾ Ä9Õ^8÷ŠÍàS	ŸõğYŸ
ø”ŸëÌJ\¡Ö°«9XR~îsTÉ
l^ŸÒµç°Ñ²´µç°åÉBæDQkçPQ¨¤²¹ĞQÙ\è¨lö’,cNô\6‡z.ì*XQŠf‰ŸÒ¹P{é\¨½tÔ^:gj/Cµ£¢m¨lÛ\(Û6Ê¶Í²ms¦lÛ*ûC)ä5ÌæPÕ+-©(ñb®ÇHYÿ¯Ô¶~­Rÿ¯lıúrÑVZQVQ:_ÿíÃ8Ôu²ğ'PüZm¹:ğÛêdg™×µÂÆt.ÿH?«¦«“µïrj¥:YH'ÕÒÕÉŠÆâMQSya¾W«T´ú¹)ËSæ‡ò\-¾@ØgTçéa.o“ŠN=¿Ôu¼&¸¼*+˜éêx‰ü‚TÇéÔu¼R×É²rOêd!-˜h'ø‘ËUS½³ZuA²«1­úĞ<‚WôPkS(€ulMåå©hõ¼pºê:V.×şP,‰N–—§‘—g /OE»\wªùY¹¼J­–‡s[¤¢Qo&·®vÛ-öšZiÚ%Éô0/xf’íÿëeŒ—r-°\ûTEÂîX‹>Ä_	m\.®/¯ê‚ín'9Ğâ[±+ï…)d)õÄ:²ïùÇ}‚Ğ–—\OìşÁzb¢FoÚ#ï>eiêã|œüÙ´ãG›Êÿ£ó‘º½Ã»†w—q™lmXç>xÎt›}Ö²JH–·„ëe1Û_F•ûÖÄ£‘5ÇX
ÇÖì÷xP7¬İ€gÑ˜×síµ%ë$$ÔÉaÿf¥•³RP·Œ§(§2IÎt®†ä7P½êMjF¾ª$>ÚyÕøÉãz<®¨jàk¸^GIÎJNã>ÎóÇü1ÌóÇü1ÌóÇü1ÌóÇü1ÌóÇü1ÌóÇü1Ì3?øÄ®#¯wÛ_wô9àÿscÃØÁó¨ï©‰ìÓ¹‰Ü­øöƒã‰?nÁÖ>åè¶OÉo`°:ºL9™bR³¯ãıOáıÇíøâ2¡—3àÍpù8{ÿ ½U`ÍÅßÖß*XZ•‡ÏVYå8"^(Ä
PSw2]GÎ=r&«àØW@;{àY
uHgàËXî=r_°şœpRp?¾Á¡Û~&ÿÓ£S>÷·ĞÑ5ìè¹9GO.şwîİ9YøÊ…‹ñwB‡elz¢àröwÕø7Òği„ş<„ÏA~…Q…¸x`Î§İpòY<Ù'?Á“ípò{<Ù'Óxrœ\+?]'ñäZ8Ù‰'WÂIO.…“¿Ä+œ¼Œ'XOç;À~§´U Ó„£+>áèÚ5îèª«é²ÖuÕwÛNå<˜´¼¥ªååJËÃ5ãŸ­ã»ğÏítïCí÷é* ğ¿CgÄZ <Ÿ× ñüÅœÀÉ¾z'– ñWü¶^8ÿ:òo°OÅóÁJD!¾ph¾ã»¬®Û>Ü}dÔÑ]?Æ^MÙÇ÷t$¦ãâtÜZ×½kª¾ë©ê.´§êé£ÏX{åÒDû,(şIV_ªë1ö
ü®‡Økó»zğ•ù5]e¥‰ğ½ø£OöŸ•JáSe¼Í‹)%Ç•Ji¢+M„åÒD?ÍÅ×–%•p|"—Ê”pür.óˆa¶š*Ïİl²à6MX_!*uÜJCrGuv÷<J%QaI¸ğºnª¶¥®4¨/Òé rçTãœÉä=©Ò@Êç¬„Ä¯7©J–ğA©=
ú:ƒJTóKõ‚L^‰ª{¶¨yr9 S{ñ¿­—*IµŸËfµQ&ÊõŒh—¥¯"MÅ¼6Š4)|{Ù&³Ú(ÊÔuµbXm”GéÍşX.†j£Œ`½­³Jmf=Ü”ñÊ‘UôàM©k£dózÇã¼ğáˆº\şÇ/òP¬\OB)×ó¨R/@;`ªr=™EåzIåzÆ5…YXĞD1sûÎÆë*±rdú¶gmµ\M­$¥ğá8+ïôÕ+ZÚQ5=-Õ.¯T\Ì¦¸–Á•\ÌA.FŠ
ëö°FëbûW€‹ıùÍÉÕ0Ø‚t%G†1¿dPräbKÊZÃÆÚËÔã*_(…+ìıIU+¤‚ \y»å9UÊk!u9Ôõ×¨®íyQŠg$QÇ{ş(É:¨ÿ£´UÇÕDÁc)ëŞ¸´¸„	\Z\ö¸4¸8	\œ2¸8%p)Ü(K».
¸ô*àÒÇÀ¥Q.·-ÀÕ.›¸t€Ë5ÌÁEªÜÍ&*xÿm	dxÇëoK Ã;şãm2RÇsÔ1ĞİÓHî8 km!ÔiÓ¢T×‘oå ƒ&ˆ¶¡rUTÅÆa\¹fğØØ7r•ë•I•ºI4//YÈËKJ£LÜa¹7£Á\vc:k4ƒ0Ó0¢uSğ¢Åƒ r)#k— l‚ ¬7„5Î„…n˜-„5AXXaaí
„‘‰õ„ÓBØÕÂ: ,/›AXX°I’„Ñ ¼VTò€© ìÂ&%K¨†—!ì/„)>cÔ9Œ!„5áAÛÓ–u6‚°IÂúåĞË¼(Ş•ïCJî8¬ä…rîH®VLÀÖ’6w|û*p¼¯W&[£!°µ˜›rÉ Ø®HlÆ:ÍÔŸMm;ûd`ÃLÉT	‚¤<›Í Øz®Æø·ÛÒ3
˜µO* ›T€­eRÚÌã‰ÆI¤=%ÈMÈUÈÙäŠ	äD¹erV9«rV	äÖ®—@®J9‡rNäv3[¦¹û±#«Y¨€\rìq€\ãBspKWØµ›-_ø;	ëxÇïŞ”°wüêMuRÇÔÑ/wü:úäïPG¯Üñ%êèìîYF¾ßj+&¼¬Ôâ¥TÖÙAõ¸xøàUë¸	… laşÇFâ•¡©ø«\rŸÿ­Bÿ»ºÂ¤¼+
Ó—wÍ‘J¹4³ò®ËÎ)77-ïZ%!á9Ê
‡g?ği]C¹¼«Ó lÇu#êÀv(-Ø©À6«Ül‡T`kTŞuÙYƒò®6Ø.#°%Çeå]É>{liÁölgÊ»>N`kSÀvXy^¤A;hĞäSmhNz^thÀöÆl[Åáì:o3ÌŠŒMÃ¬ÖŸÖ&5™ò¼ˆ…]ííH¶#ğúçJıó^%Oî3*ïH>b$ÿø
ği|VÒª;u«–ç0©Ì!¡Œ6¡„–qÕÀT¿œJLËÅÙ*âë©ø.RuĞ^líÊ%hw§†ös‹*)ŸYy)xu±Eê‘Ó§^%}êSÒ§ıWo’b‹	öØÿ;T%¾¶ŒÁşUï)Pß•P şHBú»Ò>OøÒ,àù7!MÒ¶Ãóo'R•25°Qİ÷)ªû>Iuß©’,«´©ÁIªû>FußÇäºïcRİ÷Â5Rj (©A’X•Ô ¥'Õuß¿˜'U§WRƒ<ÃÚî,5ğçe
H5Ş»Ù"@%o¼*>ï8ùªø¼ãùW%ÀçO¼*>ïøÖ«ğ¥>êhïî9Iy{T¼sJ[Õ½——sæ&T©ø¦MIŠ™o2ñ¼tÇ•°É7Eßü-†ˆ’ëL`ÿ¤aU÷	óªîÊ¥™ÁşIÃrª&ª-®n
û‚û‹˜´ÙÀÚ©Áä"ÕûÖt°Ò°„ö@ZØPÁşy«Í` ìŸ4ªê>©*¡}’Jh
ì“QöL¦-¡C¿nH¥{“aÿµû“JU÷AöiĞ4yÀT°ÿ`Áş`ìçi`¿•Õ½æ^Ö.¤s1CØ76öm2%ìK !CE©»]ÊÑ	ƒw+ÎíT97¯Hí4pç;.wv­T-¸—#¾ñ‚M
}Ÿ4-ôİk²|m™nóBßfz5ÒúO'öî?›¬Ó>E‘½JììT)’2*^«è‹­Zß¿ÔšWœœÁœ4,ô0/ô­\2È`[Ô…¾¥5(kV’Â!Å.UËá)Ø ÁîF»ØºÂ¤Ğ÷¹E_ƒôˆïÁ^¾umê]º$Õ¢4û9¥øÄ¤²	eíªµçQÎ4a°ö®ı–kxÎôÚ;Jn´ëe%7ª}YÉnzYÉJ_Vr£«_–ft<qéË8¸2Oª¢<‰ìë1ã‡¨¬<ËŒ O¥<i˜ò¤a9O–ò¤É«¥<‰åY”'M½/çI‚’'å±<iT'½wT;[É“^;ò$¢Í“?Ï0‡ÊÁkß;/óÜÉqœ™ ¡ğ(e<ßxIÊšxÇC/IYï8ö’”5ñèKRÖÄ;š^âY“Ôq+ë`ƒu÷ŒRÈëıS&•ĞfRJÎÔËs&nX¢’TU*S®ÅòVLŞÉÅ¬f¶cÄ+ËM2©QÃLjÌ<“R.Í,“:·Âô¦™/¿^Ğ³u‘²ÂÙ¬"ÒÀr&%¤Ë¤F3©ş´™T¿*“zêJ³Lª?M&5j”IM¨2©QÊ¤ÈmY&EFÉ‘RgR5ô(ÓA.ªÉ¤Vä±LjBÉ¤”LŠí A“L•Iı‚¾Vµ$eR|x9“ú.~!Ë½ì¡6şt«ó2ÃdŠíÕ-Z#g22³LM>õíä|J›PæDò)yâHâP¼¼Jååû”ï´~ıõO€_/Ùh’IşÒbò8al’íiM²]e’%¢™I¶«LRóè‘d’ƒ’I¦4ÉÁ™˜ä÷s“Mr°à³?’¢Q–5~OŸ5²hœ>íc»gÊjX‡T%9Õ útë79”nÚc’uÿ,G±nÄ{»©i›¤Í£¦is§ÉêÛ3N›Í$hï´i3OÀä´«÷l²ët*ÎÒ® e›ÊY(±&ıÊO#a×Á÷»'~¾Lo%ú´y¶ûøñluÚ,­iHYÃ ’Aë¾@¥å›:°.3I›Ïjµi3ö±²üCÁòe<äJ)3ûsÕS.£î[b1Pr³ÁÔ¤êrKTÓRªfp¯ê~6ñ>İ(ö¹—ï±ú‘bwÒ#Å©‡ŠT™2à½»¹áLMvDL(ş0®ØÒ˜Ê–¦Ì¿¿¯lé™KùcÈ·ÿ[yôøé	åÑãéÊ£Çã'”GoŸP=¾|B5©ã‰Nàø<A3|QUäÅ6SÖ d…ÿN:äj€cİ@¥¯ø›Bª}÷$í©yÀI“wfEªSROU0=è×…äAo©+JßÅ“J^N“ïØ—K
?ÒÂé_üØ9NO*)iÌ”²pºN`Ê2á†E»
§ÿğUáôo]bV£Ò*©X²É„b‰Ü<Á<%›Ã4Uå¶Käº”#¤Æ1óº”)Š ›©D_—æ*¦?w1¯KùO›ø¢Uå‹òZÙ_QV=ŞTúµ6±Ñb‡R®Õ¬¾¤Y¡[£e~G³Ìÿ¼ˆ-ós‰/šmÈ™eÙÑĞEä)ß×„]}_3ÃN>ŒôN’0@ÅI*²²¾õafèBòíè_¿P¥®0¨«Q }À&ù ôTs…õñ¢Éü¼k¬+uŒŸ£RGğ¼»ª²Ëşõ
ìoZ€B¥Â¬L•úqšã±åú”:¨·%³ßOS†Ÿ¡ágl6õ„ÇR ƒY€4h\µír(Ë¥m¥á·†lÿk)mãK€ó‰_-ıPBÙÑ¥„²ÔÑÊdKú ®eÓVÊ&­&õ¼‹Uõ¼E2ªÑª”×eúàõum]öQ%‡¥R»C¨uS}D­I(9H:Òûşp«JiPÚúİãªúİ©‚€qÂ¨ğ7GIX(şpÏıW*”<Z07‰È,«[i.ÇN¤KDÌPe,•ã¦Jëf¯59Èmú¤2Ÿ´[‚Ú½:ÿ#MóşîüsLóR:uiŞ9â6Ló~¹DeÀO/ùHx;ÍåØT:›=zd«8M 6­û-WÏ<Õ¶é÷àÖóhğW±ÄÆóL"¶¨ŠØ”‘¿°˜và	Íè¢ôÈSPÅÓÜux"U Nâ ^‡çÓÌ;¶ ß]d†ñ…jŒŸËÜöÁE2Ş›?J›yrÊŒiBïÉïÕ‰jÁ"÷Â¢ô,ëáƒ° î<² oÎ6LJ:j.(ÆänW"e¾Š¾—*–J
»Wc.¿ZHæ²Íåù…º¹xf`.‰9
ü:sÁ7®3sùù‚¹2—Y†üÆd._Í0ä›FâT:J>Ì#ôÓjeuhLåïsÉTîDSéÏı£óšÜÿ©Ñ9”£ŠÎ9º»½ıQFç»³¹»á¾¤Ñù¬ÿÑ¹*K¯ËúĞÍåYËG7Y¸¹¬µ|ÄÑùŸ…?ùè|± ŠÎX½à'?¾úKM_ı0û÷Ëìß~öïWØ¿_cÿ~ƒ•È¨ë)ºNª¦¯Æ¶·å>_’ ÂZğò©“x¶ÏNàÙ<Á³»ñìŸÙMáûoğèyã±ş?>;È«˜*´¶ŸíÒÉÎŸèù"î˜?#>·§Åç=¡à_d¿/èñ•(÷Aï§ãûİ1Ÿ¸?âöú}Á˜Øê‹µ„¼b4
‡¯éƒÃ‘Ğşˆ/}Ü8‰n=x¢’ç†ã1ñ€;âw7|QÑñ‰î ÌÁ{H…cşVÿ= Å±h‰°+xW0t0(²›%ªùGá>1Ô¬’äŠAÌÔ@=ÿVw›¿ÕP­ÆĞŞ7úÂQ .ëÅ°Ë0#,šê6“ñàN®bµ¼pÄªõúÙ-­îXÄß&zÜÁ1±É'ã€ØŠˆî¤ûh“Œ·ƒÑòú"n Wí6÷¶¬ÑÌË=;K›Õb]²0¯×ÂjUcıhÁö8½¾I.ù’ƒN™o½/+K‘œ¿ çFh€‰_F>,é²ó•šò­Öñaíì2Î·Ù”o£ïøÜÄùÎ·˜ñåY´|ø“óÿ@|ïš÷¶n¼r¸åEÎwç3¾İ´|¸å'‰ï·¦|:¾¯Á-ßx†ø>‘gÆwI–ï$ÜÒ5J|Å‹Ìø–/Òò]¡ëĞ/‰ïóKÌø:–hùê€ïù_ß¦û°N·Xƒú§¿!>)ß^Ö0~ç?‰ïMÓı;¥Û¿? ß÷^!¾×Lù~£ã[Wöş–øÖ˜Îs•n^¸²ëUâ;nÊ÷´ïa¸òÊk3_ß‹påK	âk5¯E7ŞÈ…vŠøöšòíÑñÕ ßÛÿwæûwøÄ×‰ï˜)ßgt|? ¾ÀÄWcÊw³ïuàk{sæş~<ê\ÿ;â«0Ï¦¯øÖOÎ|¼/ ß;œ¯Ôt¼ÕºñFñïìşkæzÉˆsö­™ÏóFàşıÌõ¾'ÿ0óñ¾Ï¼=3½¤;çué†yûo_4©}øhªšˆóÇü1ÌóÇü1ÌóÇü1ÌóÇü1üIK¯°îÜt+´U.×^·ó€pëİ¶ş©i~Xz±?ènÔ}Vy¼®h,Şäjò½¾ˆĞ>¢\F¹3‡÷ßm½ Êµu{½Ó…Â._Ğë
†ºı1¡W¸»0éZ0lC±PĞïqíû½>¸××ÆîÓŞÉ~šÀ[‹¥[Ãîˆ;ğ°³
õàò´¹]±–Hè «Éíu¹#÷!á +àîµlÂXˆ°PXP*üÀRğìw5G|>§W˜Ì*+CÒëkvÇ1&½ÕóE¢„·³ÖÂ%ç–ÎÎ[¼N¯ßîÜâop5”º¼Î[˜¼Ûï·7”a§¿a½‹]e—„®ì&¿g?¬ i2:r„,[@xÁ‚sp±‰@¿ğn–=ÂƒY’ô²Yˆÿ<ˆo=†<~átV48à‹ÌPLi^ V°€x+ÊÎÊ&6
ÙÂ#7Ã?'ğŸ‡ªàŸ¯l‚®„¬ğ¬Tú^6¬u|í9ÙÂ;NûW{áŸw‚BğÈ½˜buéæ¬w-/-ùíùm¸àó—şSÖf½iyÍò½¬ãÙoZŞÈúĞÇ²Ÿ{ƒÏ÷³¤3æ‡Y‚§×Ö“_rºyÑÖl¢²èœş'Ñ_äô—o%úWœ~aÑËsˆşÂN¢[8ıÙ]D—Ó¿»è·8]¿›èõ¹Dî!ú0§Ë?Eô³œnkäó]@täN¢ïàô7÷ı5N?â"úMNŸØGôõ‰¾¤‰èû8mõ}‚ÓvşïeyDßì#úÓHÃ&ø÷“øësWEt§÷]Nô.N_yÑœ¾X$ú‡œ>ÁïÿwN/»’è-Dï]Cô6N*&º‹Ópş>éúz¢ÇáÜBÓ$}hè²’éõz£Û¥o…mzİ/Ó‰Î–h\&.—³>WÁçjø\C—«V¤¹G –ÚçBH\—âˆÜ1wáEj ô™Çl¸8Ë œåÙÆ:»¸¬j8òœPÃ“3AãŒpXƒÀRÒÀ“„ôP¬ËCf½]%®PkØÕ,±ÍŒÒ9QvV¼˜sR:Bæd9kÏÁ©´:97!¥s!¤l.„¬=WOVÌœH*3Ies&iîôT~îX—¬ó9’U:‡²ÊæPÖÚ9”Åt_W	HÍ@Z˜?Îíø›ÖÀ4_Xêoú Æ°Ùlë+*DÖ®£ÖVVN-?ÄÒµëÖ—V¬[[Zam¥ë+lå‚XÆ'VZRñÁM.‰Låwpÿ!¿é}p[sª¿uàëÛùcş˜?æ?ñãÿ¸vé & 