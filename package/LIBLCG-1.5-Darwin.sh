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
  --include-subdir  include the LIBLCG-1.5-Darwin subdirectory
  --exclude-subdir  exclude the LIBLCG-1.5-Darwin subdirectory
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
  echo "LIBLCG Installer Version: 1.5, Copyright (c) Humanity"
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
    echo "  \"${toplevel}/LIBLCG-1.5-Darwin\""
    echo "Do you want to include the subdirectory LIBLCG-1.5-Darwin?"
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
  toplevel="${toplevel}/LIBLCG-1.5-Darwin"
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

tail $use_new_tail_syntax +821 "$0" | gunzip | (cd "${toplevel}" && ${extractor}) || cpack_echo_exit "Problem unpacking the LIBLCG-1.5-Darwin"

echo "Unpacking finished successfully"

exit 0
#-----------------------------------------------------------
#      Start of TAR.GZ file
#-----------------------------------------------------------;

� ]K�^ �}\�Օ�3|$�C��UlC}��	�!a�P!�!���L���3�̐7��EV~k���ۥ����n�nuY���kP����eߍ��~L6ڲ�nQcxϹ�>�|����<?'����s��s�������@��W,|���f�T^.�r#���2*�%�lظ�����|C�h+ٰaC� ������h����������n��I��u�������?�i)j��� }l,+3����%���l�7�l��/+-�(��i>	����_�n��N�k�5׈S�9$�����#�'�\{�;�["n���Ad�
��[Zcb�g�Xj+�|m��t���/ގ��F��J�'j�yBmk��*kT������W���Eڀ�
�����������ϻ^l��|89O�;��[/�B�;xH�"Q`5�����vüÇPt����h�9v��A��FC?,�+zC��6X�;�C6���Xk���7p��ײq�>w ��"ޖ����P{��=(f�HN�3�n�m~>���Q�n��Rp��Ŷ��ߌ���/���G[׋^?Joj�Ac=� r�j�C1��Ɂ?,�-Z�#��Q�1��(�l�%���f��	��>����ظ��yb؂͡@ t�6���Ң�ỸB|lYd%�PfMS�	+;�oE[�`M>�>�Di�*�,�� W���Eظ�Kִ�a�ﺭj�]�i�;�o���W��W5 }�z�]��ݻD豳jǮ�b�v�j�^����E��N{C�X����9kk��\�c[���7�[�uG�.����f��U����j�(�ξs�Ȫ�5�5���GY�kv�@���w�U��j箚m�k�v���;��v�D5H�Q�c�N�^g߱��6�~+b����Gc���'*n�w��Ys�c�訯��C�V;̯jk��F��m����[/VW�U�dg\� �-{�4��vl�Q��m�j�w�z���ص���ܝ�d��j��Ū�5���;���JQ��T�� �;	B�'ntAzw�]�)V۫jA����&/_~��9��5���m7�˯�:]�����z�p���D~̥9r�-
����aS$���Ch�<�|��7���#������}"`��ɹ�Y�,��)�슆|68[+�CyE8Ԑ�z��Avt�%���m��.�����e���1p�x�/��n�i=���d���Rp9%6�~ѻ�a�^�(ԿɟB���v��;;'���yK�/?b�_�;�v�b8�"���9�s<�p�܁�P�1��	��*6�L� tH�sw���<�0~H��|Qv�2�sw{ &p��Kl�"t��'�<��0�A�4 ͒����_�|�s����pɳ������Q �*��� "EN�(���8a2^���>JJ�x�#n�!R��V�����l�cwc!&�	����� ����v�@��(�Y�Ç[.>|���a��D�&��pU�x��5�go���z&� z#�,i^ ��������ҵ��6)���~�%�^�����K����]���]vg�Z�������1�tc����\ ��a��=T�U����|Ae�������q��HzG�&�jv�>vf��q��44r������KF{#"�0�A�2Xv�yht���8�0�G�i�1[�4�B\����ք-Ź������R��LV���(��b]����Mnϝp,�	6�=��w��p�~�����NWu ;9�G����p�]���cnX<(��0ѫQ: �e��r���a���0>#5O��ɩ���)����Q��A�f�0��`q$tPxh���q��N��!�W,\��qw�:\�Xdm!6�����'T0['v�WS8wWU��O'��Zؘ;�
�c`�ƴ��F)
�vK9z�.�>�x�n^����C¬���b�jQ2��̕iW򔨆S:�9�Ι�PI���[�¢|ۑW�@"˝��+Cx�����b0�����v_$Ģ���vڊP8���9��Ç�4��hpC�k�F��tv�xp��L'G+i'M�mӵ�ۢ��:[G�7hu˝k���ڐ�͎��<(K�1�g@ϟ@h�����CQ�j?����I�,�O�g�U��{ph)HT-����BՊL�_�ϩ�C���h�E����/gg����C�dBdW�8�E'	�A^'=^2��b�(98�r@��'A�5$�k����
��R��L6"M��|�;ȿ<����k�RW���5@`��rY_$��@����2��&�-���4!caw\�Y��"M�d�U�mM~�����z~Ѯ��9�#��J	�EZi��4��?l����5���*ȑ��d�8������*{*}y=���tkPN��Y���WH#_7��<A���1�/��(�:�x()�J�.8��`����l��k"��M�x��Nճ���B�P�����U�Gݵ&#��][kt�nb��7L	��=*�$�Yh�G��x}r�Z'n5����LPL�~�-Q�7H*4�	w�� "�u˯�����b�����bz��H����C������W
����>��>����#���KJ��_f+_���#�.���nY~EIq�M�$WR�����VQQ*��h��%��b��2�s�r���ao]�}��P�s���:���A���^�/��q^Z,T^�˃����cP�\����wL����7{�^�ݹ���j(qy�7WH(���J��߰���r	�3�_i Ԝ�H�$sCBh�Ė�?^���~�/�������;j��T��"�Yބy�3{�dbo�pLl�����'.
�����uv)�P&��L�,�8���%��0�7���Dz)���~.W��S�\�]�=���7)�p�0��6�Nu?���e��D.�/C��� d�/��#���J.o�B���T�kU�r�CT��X���JI?�����l4��g��Pm��\�<_+X%8����\��*G����
�(W�%�c��?�"F�u
	�k�����<Ky���x���r{o�#A��)��9l}�Y|%� W�@v=�k���5��7Ş#o���t8��+ϱy��
j{r*�tv�;z���>���<��\���sd�q�Ȍ����x_��>�e?g��p���śP{;������U�9��L�Uw#�[�`"z��9z�LFޱo�MV{��,yǺ����ڽG�,=3;{�*T���'h����FS<:�4�=�����l��/�Y�������٩�K�*���1�k��i>��I�
��rN����R/U�K��J�T�F�\.U.�*V���W�6�tw��O9zvO:z�&�{��=u�G��g<�k�W��|��H���5_�m�:l���~��T���j�5�RE�K�����\�Qh_:�v�tim�}��ȸ��n��腅�����l���w�L]ϓU=hOU�'G��J�t��-(��������GGY��+������z�ڞ�Al<�Bl���k�*�`�M`�^gT'���S�Z����C��(Q�g��f����BήQh���ǳ�f�}(�9�7��y�OF��d⽯e3��1��a,{�d7�6�h�{�a��=K��v�6�q��V͂J��0��Y�f��@�Q��@W.��ʚ��w�4}��{�q�G�Xc���oڧ�J����@�u���� �hn�oR5a� ���}ʺ���<Ɇ�t�
��e	qIB������>X�q���qܹ��W���(�{�w��h�1�EYߘvYGbfS�����f��m���#�����|�[�Ƥi��O��v�:��p����=0�Qf�սG^����M��>JVч����y�Q2��u��=4zl4�����df�Ef[l���1hg&z�u@%y���@��`O�^�}���A�����)��4�h�7��p����c���6s���ƥ���m�C�����̤��I����+���!$�U]��L�b���+�U\�A.FT�8˴������S�1#�ǘ��,z��%�/(��E�liߔ�7�Z{�z܄��	E{��86rr�V$Wu�W��GQ�S��VR�3����_��ZsF��I&K�Ku����������2L��A�&pi%p�O��H��$pq���ԃK�.�
��+�2���Q.�.�Yv&���%.��r�sp�r�Vݨ�Ćmð�a�����q��J�ӡE�!X��Yy+��0Ad��]����L5�����L(�Ǩ�JU�2ErG�a�ffz�h��h�� ��J�:%�"�Oa�+�5AXXa�a�
�����SB�Uº� ,'�AXX��iv$1�A�h���A؏8�MKW/C؟0S|�>�sCk4<��Mlo(��!lP>zE:o�_�4�*r�r ��1_���
	�Zӏu��[�9�)������f��t��ئ�q@6�d�L H�s��R۪3�>�`6bl���u&�i�
9�\!��H ��@�J g�AΪ�J�
�9���@n���_���L ���r�k\jnP�r�����&m��b]bð�aH�0�m�6�k�{�V����
	/+�x9 ���>U~��Wv��M(� `+�?6R�]"��~��i��7PؑZo͑J�e�x�C�c���)6O��ߗ��RBd)+���#��G��Gi` [��N�Fԁ�HJ�IlGT`�9�خ�`;)��$��M��	l�q�n�d�}��`�s���j�}��֦����H�vѠ�&�&�>���Ѐ������هt�f��`�6��t���1l�D��`��퐢`{�'�8��*K#HNXu�n����9ĕѦ��eR5�-	uӓ~Zо��͡]�e ����~n�J�g֮�Yr$������S�>(�Ӑ��7I���BJؿ�}��!��>��U�_U�VB�ʤ��-��3��`��Y�7�N~�B��Xh��Xӄ��(��U	�Yh�����sp�BBhЕC�A�Ah��I?�����C& ~bà�a@�Яm��6t��a�f?hu�I�UE hB��IP���M	
�o2�]cuM}@�'�o�s�}��}&���[s�}6��A�Lt0]�$�_�DY����>HK˰oM�lD������`(���:؟�@�}f�}�)�Q�a�䰟E�nt���Y�i(��
�Ӡ]4h��`��,�������~[ ��Nt!��¾�it�i�Ia_*ZIݝR�N�Gqn�ʹ����䈯+�<����ț��'���7Y~�i@���~��I��b��a��8�0�a��p�l�NE�+gg�J�Qur�s}ѓV��C�ĕ���As\�`�kS�0��#�]���C��t����;}�#���:��¥V]����*h�sF�ie���ڧTkϡ�i*��Y��ƻ��b#��'	I�J��Ⱦ%0~h��	���)N�8iT��F�q��(N��@��%N�aqҸ:Nz�9�8�'�m���
�*��`E����83RҸ6jJl�6�k����6Xo�8yݠ�I����H�[���y��KT��|fXlk���wr1�#�q�Hj�<�Rn�-�7�e��Ձt#)4!IݴLY����"C��Cr$%����#�����`Z��`�Hj�(��RER�I�۲H���="%����Q��\TI��a�ԔI)��E�&�,��9}�jJ����r$�}�B�{�C��V�e��۫��F�d�g��x���xJP�D�)x�H�P��R�����L�Ze����<N�dgJ��L�$;U&�y�H0�a�$�����\L�ى&9����
��8� ���g���S�}l�LY�j�HN6�>�z%�­S[aL��f)֍b�45m��y�4l�6Y}g�a��m��2l��v��Mt�n�Y:��P9֤_�i$�n�<n6�w?����5�(kV"h�����4�@5��j�a3?�.`�q�Q�-����aTO��λo��@��S{���TMNPk��s��W�g�#Ѝb����)�$<R���@'U��w7�鳉�O��)�&[�P��L߂�ǐ��[�ߣ�<)�I�h�O"G�t:z�����٣�}���	��ux��Oa��R챟�V��'z����s����y��g������I^��4����^�Xϓ�ݞ6vt���uL��F����ˊC�ڃ$s�\w&��;���nX�d�/�a�]��V<Au�Au����}�"���#)2��V��!��I��V��_�VT�X/P��Q}$�"���2B��+r,�;��6v�Ma����N��*��Tş'T�V�b�:Q�VIŒM�K���)��nd
U�>���qB�Ƥ��J��F�����W����r�ѭ�-�UeՓ�@���CI�:i�/�sX�����E�e�<r�B���E�S�;r~�9r�Iװ�Fz'���7��4?f�u>u 
��$���B�0��\a\����J��uT��{++z�OS+�MP��a��PJ�^a��I��z[2��4��3����H��X�8��H��&U�.eٴ��4��0a_:�v�%?�L�$�?��<�dl�f*!��B�|2Z%d��� �������G�q���z�(9L:���h
�JjP��8<'��A7w��<G�\����1N����$,�O�����8N�I�%���R"f�2��q��u�;�51ȭ�1H��a^R�N#�3���kR	�1���x&���=��U�� ��m	�>�~�m3߃�=��Ge�kv@wJ��10U<��QwO%;��Fq�\�ۓ?��1~�c[����f��4b��{2�{}�j���,��ô������tԜW����x�x}/�Y*)�^s���l.�:�?
s9�#��i��'q2�I�'�Sjeu��������x:/�΋����,h.//��zt���o4t���#>���ެ+%r(�����*��?���Մ��K�Ƿ�JI%y�`�=��D��#q`�Cҫ�A&jĢE������� �H��ԯ$W$��b�3�PϿ�8�Fbo��c%�F���4`��d<TR�Z�:=
0�"�|����F���w9��F�������Q�;�;�tv��N�r!/-w�,V�u�Ҝ~��2h[�)�z�*�!�&�z_F���%Y�CL�6��륆8_�)�z���	s�m�|[t|Oç��g1�˱h��O�=���эW]�_�c�ߞ%Z� t��|���M���
���|��1�8G�w����p��˴|f�q��}i�_�J-_-�s��L�a�n�_��������*9߯M��n�~|9��S�Wt|�����+6��:�<�pg��7�{J��U�������"�)�|m����[�%���>S��:�j�y��w�:9�1S�{t|?��_��U��ݨ�{�����߯�������t<�n�F�|o��}�Z9_��x�u������%N��w�>��o�ݹ�%|����s�;7�,������B1��Ci�����>a���vj���OTS�5����6j��6j�b�o��on��SU���vW����گ����Jj�э�^u#���H�}[�}�j��B�]7P��7P{��~�����u���u���g������>C�͛���
j�?ԞSA�=����&j��Fj_���/�H��S{Q9�_VN�g7P{�j�}����+J�����+��[J��QB��٨�c��[m�~O1�#���-����;:6�����m(������c^�xy;�0�������\C�r���eװwԭ#ڱ�����k���k��<(/������+���O�=~�_�e/;x���[yy�e̜�����˕�x�;��8/.Ҹ/�$���������bN���S@�SяC�I���)���%�~��.��%4�^n�e	/E^��қO�?�	��4/_��$/�y9����/?A���=��.&�Jh*��ED�A	M_@�~w��J�Uд��s/+yY��O��<^��RYC/�-�U���|��O�r(���f�����Tp�J����_.�=���A	C�.�q/㥕��˸>�q}�p}��U^�4��=���e[0��迀�Vpw6��,j���<��I��˯�r)�T� ��5��P��ܖ���Z��4B���m��P�E������������[�u{l� ����,�]���m�j�(��/�q�;-�}�M���F`��o	이���#�w�^ǎ �k�!�v����\+���X��VrKp��Nc	.�;�M4��ǹ��\&w?����-�4��J�YDc	��;�i,�Ur;9�%�y���X~���X���Nf�%�w� ����m�4��6Nc	v�;�A4�`w�����&���X���:9�%�Kn>���r�,Dc	��;�i,�.rÜ���
Nc�M��X^��@4�x��s�B��pK��\��X���vat����zUn����'�2��RߜEt+�/�$z�Ө�Os����g���t!�s�Nwp:���8]���QN?��w�4_��y�Z����e+�v.��KxV��"�ϓtp�����
�K)�_���6�$��'����/��g�d��&��9�[�}��p~�g�����u|<>~�Dpy��o,��7�H��DWU����"��_ry�m%����_(�ry�U�/\��v���/Q��]�v��]��/-]��~��}�ӏ��NG8���
�?�/:���yD��%�y}����	oK�	O������5�g5�W4��5���2������:�+
�]�P�-�BA��������� ��>E�����/���n�������H�`]�)��R"hS/�<nW�5:�jr{],���+���Z,@���'���>�S��sϘض>�����)�Oٹά�j���Ee�>G�����)�p-K�p[�(dA�a�J*]�.��J�� �2Dϥ��R��%h��)Y��,��K@�%���T;*چʶ-��m�l�(۶`ʶ-��?�D]�ׇq���y��c$��Wb�TZ���V"�J�K�6,��(.u�,�I�f��g�.�6B��Y��y���1��?�Ϭ��f���J)o�	��ty��������0߫u*Z����)�Cy�V_ �3���U.o��N>��y����J�-�_��z�������y���ͲrO��f!�)�_h'���U]��JuC��1����<�W�P[S(��rM��h��p��V.WK(�@'�����1����]��;���\^��V�ù-SѨ7�[[��f{u�����Dz�'@�����73��rn�l�TF��X����$ڸ\\_N'�	��Ir��ķdW�+0��ue��	�	BkNb~�����i��.ei��S|�������J�-_r�!�|�����dküg��:�m�Y�:!Q�ل��b���2��G#Ł��(�c�-ꆕ���y=�\S�QBB��oFJ9-��e<E9	rf�p5$�@���oU�0�U&��Ϋ�O��qEU_��Rq���4���x-^���x-^���x-^���x-^���x-^���x-^���5���PA�9�f��Mǀ�q�?<�96O\AmONe�Ύg߄oC8��v,�3�^���F���Ȍ��!v+�>����̄~΀���q�>���g������[U���TZ�8"��ǌP3w0=G�=r&#��7@�=p�j��c]R�|9˽G�����@E�J���F�^��l�_E��,���_CCϨ��B�}�����fe�+.��	��٩�K��Y��L7��>��t>�	F�= �s>����*�b�*���v��b��|V~�*[�rTva�r�D�r	T�+V���̯�=`�CڀJ�i���>���=�詛���ԍ=��u���VVw�juK��������]������@�}������'����@<'p���+��3ޭ��B�����\�Qh_:���]Z�k�=2�譛`���m��v�g���vkm��'�zО�fO8�>m�S����'X���G�+�{b�����W�W�t=r��*���;�>1xVJU�5���j4CLJ4��t�TR:N)���,UJ�S����1�HH��x6�#�4H���l��l74Y�{�d�m�016�RTj��F�Jj��{�R�Òpᵽ�}K�=hX���A��)�9��3|R恤9�X+�_mU�2L�R���y5��������"U�rm����@����k/e��r->��r�L���.K�+E��y�iR�z�ҭf�R���rǰ\)�Л�1}�J��[g�\)���)��%���N�s�dR:�I�qL���uL
&���ĕ�=�(��&K����'���gR�1��	N3���l�0��(G�o�f���NR!N�tOoS��U]���R.�
��l��aZ\���bt@Q��>Vh]�e���oL̎��KA2�x��-�$Y��6�^�g�	CIdaL�b�$%��ۣ(ϩR^+��i���@u�o�I*֜�D����$�x����V�W�O$̓7L��A�&pi%p�O��H��$pq����%�.�
�t+�ү�� �F5�ܺ���pٺ���� \�^b.R�^6iP��H ��|G����p������޾Fr�!Xk+�N�u�<�|+��0A<�����6�L6�W����{���dD��M�y��|�nRe��Ƚ��ק��F33=F��`
^�xcTn�a��M���������u�F#� �� �S�02��pJ��CX���d2+6͎$a4(��8`2���i	���e�a��؇uca�����i�<Aشa�����)	߇���#J�8�Ď�r�H�VH�֚2v|�Jp�oU$[�!����r� �.Kl�:MןM�md`�H�d��<�� �����o�Ug0�V@.6� [봴����8HgR��&�� ���ȉr�	�rV��m�$�\�r�
��a �Zr�czF��P�J���0 �ƥ���*�k/[�.�7����Z�:���_s��~B�rÏ�a@n�5��_���޾������B��
-^Ji����C<�7�������H<S4%���B�7�u�W���{Ea�t��9R)���u�9���^+%$�I�����<b��PN��4 �I݈:�I	�#*��(3���{]}� ݫM��	l�qY�W��>[J��9[�Y�t�����U�i�.4q�d`�D�G���>�Vq8�����"c�0����IM��</b�W{'��<z���_����=������|�4�+a�ݺU�s�V�WF�R��I���ϜRN��ڍ2����N.�Ru�^h��-hw'��s;U�>�������"�O�J�4��OC���$����7�J|���+�W��'�@����wť}<�ťY��o\�<�ƥm���8N�2ih`�<�3�~���SfY�yB���~���O�y�'�<���Rh (�A�X�� ��'�y��<G�V��]9���Yh��I?�r���E�J�z]|�p�u	�y��K��]|����9�K����w�2��;(;/x�6�{?O��M�B�M�2�d�yZ�)Ji+�o���Eך��I�,�S�Yޕ[s�����U�LT�l��	��/1Ip=���RÉI����`��aJ����?�����`(�4��>�J�}�Rj
�Q�M�L��E�nH�|a��,��J��a�i�.4q�d��`��p��h`�����^։.�s1C�76��4m2)�K�!CE+��S��	��(��T97�P�4p��/wv�U-��#��M�4M��o�|m�n���f�5R&��&&�<���E����٭R$ET<':=W�=Z�~�iPkNabs�0�w�<�r� �9nQ'���4��aT	
G�V-��`����5&�����5�����P�nՅKRnjA��3�OL+�W�>�Z{�LSk��o���Lo���F�_Vb�����膗�ب�e%6��eiF�㗼��I�J��Ⱦ%0~��̳��q��F)N��Q)N��J��X�Eq��r�$(qR����q��+�\�J���
��P�6Nz~�a���~�"���q�� ��8E<�~I��x�C/IQo8��5��KR���^�Q��pk`����ӑ����H*���������LܰD%��?�d@�X�ŭ���Y�l3��^aI�FR摔rkn�Թ%�7��x:�����)+����CdHxH���T�Ըa$5�2�TERO^nI���ƍ"�)U$5N��-���(�#R�H��e��E5�ԚIM)�ԐIѠ]4h��"���ת���H�/GR��/d��=���nu^fL���Yk�LFz����N���� EN$��'�$��+U^�_��I������J���&��/,&��&ٙ�$;U&Y$��d��$5�	&9,��pR���I�0;�$���S!1 gQ��Q#;�S�}l�LY�$'Tn��E�֩�0&Y�O��F�w���I�<n6w���3���L�6�N6� L���&�N��,�
Pv���kү�46p|�{�g��V��经��T��ҚF�5+��TZΨ���� �j���ܠV6���>q��Qp�j~dK!3�s�S.���[i1Pr��Ԥls+U�R��ѿ_՟M���@7�}��{�~�ؓ�Hq��T�2`�=�p��&:G<G��TliBeK3�߂ߗ���%�1���V=^8�<z<uBy�x�����	���k'T�:���4�'UV@�|3iN@��C�8�T꜀��S.�'hO��N��3KZ�,�z���A��'z[�a�N����R�R�|�6�_���&R��O�c"����LI��&Mn��� ���/V%R���f9+���%��+���3�S��	�HSU�X�S9Fj�0�S�$)��J�y*a>�bZ�s�<��p��/ZU�(��-�UeՓ�@�^k-v(�Z��M�%�5Z��4����2����9�LC��<凚#G���̰�Fz'���Y�߃�cf��z�o]�RW�5�(�>`�| Z*��x�)^���J��uT��{++z�OS����(T�0�j�T���9��B_�R���d��i��g$��31���I���4hR���Q�M�J�o�6��*�Ɨ ��\��eGW�q�%?�L�$�?�uG٬�e�V��ޅ��ޢ
�U�hU��2}�|�������R��Ժ�>���&���}4�U%5(m>�IU>�d���q�(8GIX(�p��gy*�<��0��<�[i.�N�
D�Pe"��&��w^kb�[�1HE.i��{U�����y��%u�4¼sN�m��b�ʀ�Z��p=���L*�=z��8�Al�\�
�~�m���-+h�W���&'��:�?,#��rځ�5;�;�����*���;����q��8���y4�������a|��2�}p�����f��4b��{2�{u����㽰,��z�0,�7�,�;�=&%5�bp�;�4^E�Kv�J
�Wc.�\J�������x��a.�:�u�o\g��%e.�<����|3�#��$N��8����~J��.��`�84�;�T�?�ӹ8����R�΍Y�����q��werw�?|�XO�2�G�Ε���ڌ��\��|���V7����t�G��t�HP�Θ������+�^�U���ؿ���o�����m�"�����T5�^�e�}�$����S'��k'��kcX�k���h
��W�[����a��T�����*�Z}�?拸c�PP��ܞV�W�|�_��+R�A���[�1��q{��`Ll��ZC^1����tH�A�p$��E���;�N��ۃ��������x������Dw ��=$��1��n�	���h��;xg0t0(���E��G��jVI�GŠf�?���������ch{cG_8��m�vf��C�u3zr��#>P��Ϻ��c��q���&�l��PDt'��M2�ZD[����\�;�;�0g3�,w�,V�u�Ҝ~�]����c��&9�K:e����,LErޒ�� &~�0��f�Wbʷ^Ǉ��K9�6S�-:���s�;�bƗc���O����g:�;��ʠˋ��%f|{�h����'��5S�)�_A�o?M|��1�8G�w��_�23�+�i�.����/��K+���Vj�j���_�u���Q�����W��cʷOǇ9�����������������|����Ý}�_��<����;�_'��|O���
w^}c��{�|%N|m����[	��OO�>S��:�j�{�?���O|�����ݣ����"�jS�u|o_ǯ���W£�g~C|���t�5ߦ鹏�e�{�󕘎�^7�8����]/Yp�}{���F;w�Ā���}�G��w榗T�c</�(/���&�I�q�Z���k�Z���k�Z���k�Z��?�k�e�][o������vn��683�/K?��m���J���7���A�/"t�)�Q�\�a����W�n��s��P��z]��A�?&�w�'���m�`(
�=��v��}}����'�i�J]��;������t�]��H蠫��u�#�!�+���Z6a,DX*,)~d�xZ\�����2JK����������"��k��s����^��own�7�J\^��L�������o��bw��e��w36���XA�<d��)d��O,8������!d@��`�$�t���m�ǐ�/�{F48���Q���&#S��"d
_��9��<T	�|c+���jA��K��3am������u�ؿ�������k�)V�l��x����������_��2�#�ז7,?�8��k�[��X����Q��0C�1����\�^SG~�cN7����I���DVs��D�p�k����������.��p����_��ͭD���=D��&zx/�N��яq����w	ё;��,�����/s��.�����^���y����z�~��v��nn�7���iX��>m���*��8��R�ws��ˈ��E"яp���,�W_η�B��b��p�P!ч8�u��-��D��-4M҇���H��h荌��hh;����3%��K��\�+�s|��ەkR�8�Jl�s92Hܗ��a����p�f~&��y��Y�ߡ�X�w��n�<'T0��t�6-�� ��  5���yoW�+�v5�l �dd���$.�\��,��YΆsp*�N�MH�B)]!���� �JLR�IZ8=��;�%�|�d�,�����ae1��V R3���
����;SX�o�0ư�l���EVn��VZF%�Ē7�����o(m%��KJ��O����Û\;*0��[���C~�~Э9��:�u���x-^����͔� $ 