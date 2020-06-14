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

‹ ]Kæ^ í}\œÕ•÷3|$äC˜øUlC}ü‰	©!aâP!Œ!ÑÄÅL†™¦3ãÌ7©ØEV~kİÛíÛ¥í¶¥ÖnénuY·î¢ëkP©¥©İeß•º~L6Ú²¶nQcxÏ¹ç>ó|Ìµû¾<?'÷ûÜsî½çsÿç™Áçøƒ@»×W,|ˆ—ÍfÛT^.²r#•¶Ò2*ù%–lØ¸©¤¬¬¼|C¹h+Ù°aC© –˜“’®öhÌ©Üİê¶ò›öƒnÍÍIäğuÈåÿËÏ÷?ài)jıÆ }l,+3Ûÿ’¶%¸ÿËlË7–l„ı/+-Û(ˆ¶i>	×ÿçû_¼n¹¸N„kÛ5×ˆSÄ9$†š¡ô¹#¢'ü\{‹;æ["n¯ßŒAdÙ
Šø[Zcb¡g­Xj+Ù|m©­t³¸×/Şª¹F£ÑJ¿'j÷yBmk‘µ*kTŒø¢¾ÈŸW’êôEÚ€Ã
Šş¨Øê‹øšáĞÁ˜Ï»^lø|89O«;Òâ[/ÆB¢;xHû"Q`5ÅÜş †vÃ¼Ã‡Ptµ‚¤h¨9vĞñA¯èFC?,Ê+zCö6X•;†C6û¾¨Xkõ‰—7pË×²q¼>w úƒ"Ş–îŠı±ÖP{‹ø=(f½HN…3‘nüm~>²ÓêQˆnÂRpÂëÅ¶×ßŒ¥­/ÜŞğG[×‹^?JojAc=¾ rÁjŠC1ê°É?,€-Z™#ë†…Q¹1®®(¶lµ%®ÇÏfÕÜ	ÂÀ>ÆæúØ¸ŸóybØ‚Í¡@ t×6âõãÒ¢Ÿá»¸î»›B|lYd%ÁPfMSÁ	+;ÍoE[İ`M>®>ÜDiØ*­,‚Ó WÆüî€EØ¸ÚKÖ´Ëaê·ïº­j§]¬i;ëo­©¶W‹—W5 }ùzñ¶š]úİ»Dè±³jÇ®½bıv±jÇ^ñæšÕëEûçN{CƒX¿¥ÕÔ9kkìĞ\³c[íîêš7‰[uGı.±¶¦®fÈİUÏÆäÒjì(¯Î¾s›Èª­5µ5»ö®GYÛkví@ÉÛëwŠU¢³jç®šm»k«vŠÎİ;õv˜D5HŞQ³cûNÈ^gß±«†6Ñ~+bƒ£ª¶Gcµ–±'*n«wîİYs“c—è¨¯­¶CãV;Ì¯jk­FƒÕm«­ª©[/VWÕUİdg\õ ˆ-{Ò4ÅÛvlÅQ«à¿m»jêwàz¶ÕïØµÈõ°Ü»dîÛjìëÅª5¨™í;ëëØJQ»ÀTÏä ë;	BÍ'ntAzwƒ]–)VÛ«jAìÖí†â&/_~…¿9èõ5‹®Úm7¹Ë¯€:]¹¼¸¸øzĞpÔßøD~Ì¥9rƒ-
ƒûĞÙaS$úÜÑChâ<¼|’»7·ÇÚ#¾åØÇò†À}"`¦‹É¹ÆYÇ,®²)â‡ìŠ†|68[+‡CyE8Ô™z®ùAvt°%ù‚ímªÛ.¤—ÿñòeÅÅÇ1pÂx—/Ãõn»i=ëød§„ÑRp9%6ƒ~Ñ»ÚaÒ^Í(Ô¿ÉŸBòÖèvŸ²;;'ÙêÄyK×/?b¬_§;âv®b8"¢Ûû9Às<”p×Ü–P·1µÂ	ÚÇ*6œL£ tH­swøÛà<ñƒ0~HûÛ|QvÏ2Øsw{ &pÚñˆKl¶"tËä'š<ØŞ0€A‘4 Í’Ÿ†»_´|Ìs™ÕâîpÉ³‰Âúå¹ÚÃQ ±*ÄĞù "ENÏ(¯ˆÏ8a2^ü·Ì>JJñxÚ#nÏ!RùÁV¿§•µÃlÚcwc!&¨	•Úô €°»¹v˜@ØÇ(ğYçÃ‡[.>|¸éğañúDŸ&ÌòpU‡x­¸5¡go¨ƒèz&í z#È,i^ Ÿ½½İğÅÂÚÒµ€‘6)‡ÅÄ~µ%ì^‘ÁöóK³Àô]»‘ë]vgé¾Zí·µ‚¡¢©1¼tcúòıÂ\ ´›a¾°=TÕU¯ÕÅú|AeíÀçÃñÑøq‚áHzG&³jv¢>vf°Áq¨44rËîÓäÆã„KF{#"±0ŞAö2XvùyhtÀñ»ñ8Ã0ÉGøi÷1[­4…B\®©Ö÷Ö„-Å¹›·À¦RÅÿLV‰ºç£(ºçb]ò¨¼„MnÏp,ƒ	6»=äõwÀÓpË~ºõ¢«ÃNWu ;9˜GˆÀŠápÂ…³]€¸cnX<(ÔÜ0Ñ«Q: ƒe™¢rÕÁıaè‘¢0>#5O•ŠÉ©°Ô)èŠúïöQ§¬Afğ0¿¶`q$tPxh‚q³“N‚©!¿W,\‡Ëqwà:\áXdm!6¯“õ€¡'T0['v¬WS8wWU‡ÔO'šÖZØ˜;Ó
úc`ÊÆ´ÀşF)
”vK9zÁ.ƒ>ôxÑn^ºÛû†CÂ¬šÎŠb›jQ2“ÉÌ•iWò”¨†S:†9ÕÎ™¸PI‰ÂÔ[Â¢|Û‘W@"Ëš™+CxàøæëŒøb0¦Á˜Üûv_$Ä¢ÔÁvÚŠP8¦õò9µÓÃ‡„4şÄhpCÁkïF™´tvŞxp»æ’L'G+i'M›mÓµÉÛ¢¾ƒ:[Gà¨7huËkƒÚÇÍı¶<(K§1ëg@ÏŸ@h“şÈ¼”CQ¡j?‰Í‰¸I,¸O gÖU’Ç{ph)HT-«½ÀíBÕŠLæ_Ï©¡CÒÔÑhŠE‡ÑÌä/gg“Ïê…êCÅdBdWº8‰E'	ˆA^'=^2¿Ób(98šr@˜Ä'AÑ5$ƒk™ÔÇÃ
ïîRºšL6"MÇÁ|á€;È¿<Àø“ık¢RWšº5@`ï‡—rY_$ìÔ@œú§©2šß&’-–¬¿4!caw\ÀYˆ–"MÄdÉUàmM~“çşŒ£z~Ñ®³ª9Ì#äíJ	ŞEZiÎÒ4€£?l‹´­û5ÀŠß*È‘ğŸdé8¶Êõìÿï*{*}y=ùÚtkPNøÕY •áWH#_7¥ª<A×–£1ã/ğ„(:—x()–J¿.8”Ç`şü­±lö€k"òçMx§¼NÕ³®¤»BšPöü¿³ÂUğGİµ&#íØ][ktƒnbíò7L	êè=*İ$ÆYhøG©‘x}rÜZ'n5‚¦åËLPL~Ù-Qû7H*4Ç	wƒí "ìuË¯ğ›ÅâbúêäãşbzñúH®€¿éCıí¯¹ÿşW
•Åßÿ>Š÷>øóŸûÃ#ùïËKJ´û_f+_üıï#¹.»Şñ´nY~EIq©Mõ$WR¾¹´¤ÜVQQ*Šå¶h¡Û%´—bùÆ2Şsÿr—«¨ao]µ}»ØP¿s—½å:¹üAØÊË^ş/æåq^Z,T^ÏËƒ¼¼—cPº\·—ØòwLÎíœœ7{^¿İ¹İßàj(qy7WH(é÷ÛJ±Ñß°ÉÅîr	ò3“_i Ôœ£H¿$sCBhÍÄ––?^À›Ø~Ó/ƒÛÑù²†ç;j…ôTçô"¹YŞ„yˆ3{Ûdbo¥pLläö†‡•'.
©ìø§ï½uv)˜P&ÔÁL„,ø8éş%ğË0÷7ØÖÌDz)ÿäğ~.WÌ×Sø\®]ö=»ôò¬7)òpØ0ş§6±Nu?—‹…e¦òD.‡/Cèş¬ d›/åÑ#¡‰¼J.oÚBåÈËTñkUärØCT ÂX­†JI?µ‰ò²Ìä•l4—gåôPm¢Œ\<_+X%8–ñüœ\ŞÔ*Gøü†ö
Â(WÀ%Êcû?…"Fëu
	îk²Ëî¯—–<Ky¥ğÉxŸÜår{oø#AÀ¸)¾ê9l}òY|%ÿ W‘@v=×k·£ç5ÇÑ7Å#oöÚßt8Ÿ¥+Ï±yâà
j{r*ótv»;zóÒ>ãèµÏ<ûÏ\€ÕÑsdÆqôÈŒ»€Š•x_îÜ>ƒe?gÀÎpû¸àÅ›P{;ÏÊÜàí¼U•9ØğL¥Uw#¿[î`"zœ9zäLFŞ±oÀMV{àÕ,yÇº¤Ú¿€Ú½GÎ,=3;{*Tòîÿ'híµŸÉFS<:³4ï‹=£¾»Ølû²/ÄY°ø¾‹Ğ–‰Ù©¼K…*¨ƒ‹1ìk„ši>áÓI£
í€rN»¥Ê©R/U¶K•¤J™T¹Fª\.U.‘*V©²”Wî6 twô´O9zvO:zê&ª{ìãµ=u£Gäg<ÔkÏW­î|Õê–H«ëÇ5_Æmé:l¥ÎÒ~Ÿ®TÔÄÕjâ5±REôKõÍö™ö\°Qh_:²vätim¯}´÷È¸£·nÂÑè……ôÚã³íâl»µ¶w÷L]Ï“U=hOU³'GŸ¶J–tï›û-(ş‰±³³³GGYñĞ+ú†¡¨îézŠÚ¾Al<úBl™£·k²*½`ÄM`Ÿ^gT'©Š­S¬Z™ïèéŠCõè(Q¸gùˆfêàïíBÎ®QhËÀ¶Ç³Ñf­}(¤9ï7£ÍyÅOF–dâ½¯e3å1ÂËa,{Ùd7Õ6Œh†{ûaÓÛ=KÂ…×öv‘6qô±VÍ‚JíÃ0õœYìfª@ÕQ¨Î@W.³ËÊš»†w×4}¬ø{ìqñGßXcÀµoÚ§¥Jü¸ıŒ@şu“š×÷ ‘hnşoR5a™ å˜ßî}Êºé·óö<É†Ñt†
‘Úe	qIBü¨ıŒåÔ>Xèqû«¤qÜ¹ÍöWóú(É{¬wûØhŞ1«EYß˜vYGbfS‘¶ûÀÕf“úmŞçÏ#åİöäé|ó©[ëÆ¤iá´OßûvŞ:¶ÛpÏ÷öÑ=0êQfÔÕ½G^åæĞÇMîö>JVÑ‡À‹šyÁQ2Ÿuæ=4zl4¦£ŸÊÌdfÛEf[lËûÂ1hg&zêu@%y¨Ïâ@«û`Oê^í}ˆí¢Aëù™£ç)ãÿ4ƒh7çâ‚p«åáÑcØÈè¥6sûˆÎÆ¥šÔm”C«à›ÖØÌ¤¤üI¦üïË+ÄÆ!$áŸU]•äLèbŠ‹Ù+œU\ÌA.FT—8Ë´†…©‹é´Së1#ŠÇ˜ß»,zòî%ø/(ñÔE°liß”´7‘Z{ézÜ„¤½	E{¨½86rr’V$WuíW”·GQS¥¼VR—3™ºÚ_µœZsFÅÏI&K®KuÙù‰²‰²™ÁÉà2LàÒAà&pi%pÙOàÒHàâ$pqÊàâÔƒK§.İ
¸ô+à2ÀÀ¥Q.·.ÁYv&€ËÖ%.İàrõsprˆVİ¨™Ä†mÃ°¶a¨·¯‘ÜqÖÚJ¨Ó¡E!XÓğYy+‡Ô0Ad˜½]ûÉéôL5ÜÅ–™•L(¢Ç¨ŠJU2ErGçaffzŒhÁ¼hñÆ ¨ÜJÂ:%›"ëOa+„5AXXaa
„‘‰õ…SBØUÂº ,'“AXX°iv$1£A»hĞÄ“AØ8„MKW/CØŸ0S|Æ>¬sCk4<„‡Mlo(›–!lP>zE:oÑ_ó4³*rr óØ1_ÉÕ
	ØZÓuËÔ[«9°)·€í²äÀf¬ÓtıÙØ¦±q@6ŒdL HÊs°ÙRÛª3Ò>È`6bl´™Èu&¹i¹
9\!œH ·š@ÎJ g•AÎª¹Jä
È9ÛÃ@nµäî_Š³¬L ¹¥rk\jnPòr€—ı¼ì&m¬Öb]bÃ°¶aHÛ0¨mĞ6ôkº{ûV“ï‚Ú
	/+´x9 ê¡ÈÀ>U~ü¡Wvœ•M(¬ `+ó?6R…]"ùß~ò¿ıiŸÚ7PØ‘ZoÍ‘J¹e€xÌC¾c¬«Ï)6OÃÓß—‘°RBÂŸd)+ÿÀ#šG¥Gi` [§ØNêFÔíHJ°IlGT`«9ïØ®æ`;)í$¸°M¶«	lÉqánï£dŸ}¶”`ûs¶¶“j°}ŒÀÖ¦€í¨ò¼HƒvÑ ‰&Û&Ğ>šğ¼èĞ€íõ™¶ŠÃÙ‡tŞf›Æ`š6©‰t”çÅ1lìD²á`”İí¢`{¿'ğ8™ƒ*K#HNXu·nÕò¦•9Ä•Ñ¦”£eR5ğ-	uÓ“~ZĞ¾ÚÚÍ¡]¹e íîäĞ~n§JÒgÖ®Yr$ù±•·ÈáS¿>(áÓş«7I±…ûBJØ¿ò}İó¬!ÔÓ>ÊõU½_UïVBƒÊ¤¡-ƒ…3°Ğ`šÅYÑ7õN~ÀBƒ‰Xh€…XÓ„‚ä(¡U	òYh€åĞàÏsp–BBhĞ•C¡AAhàÏI?€²“´€C& ~bÃ ¶a@ÛĞ¯mèÖ6tööa¸f?huŞIŠUE hB•ÊIP¡ø¦M	
™o2ñ]cuM}@ß'‘oŠs†}¦‡}&Õö•[sƒ}6ÎA‡Lt0]Ø$Ø_¾DYáğüÖ>HKË°oMûlDì¥„ı¡´`(ìãè:ØŸş@}f}Ü)ì“Qöa§ä°ŸE¿ntåÁşYöi(ûÃ
ìÓ ]4hâ€É`ÿÁ,‚ıáØÏÑÀ~[ ÷²Nt!‹Â¾±it¦i“Ia_*ZIİRŒN¼Gqn§Ê¹ÃäÎÎäˆ¯+ñ<‚ÓÑÃÈ›××'è¿Şê7Y~·i@œ®„~„IÂûbËËa–‹8ã®0×a˜ëpğl¢NEö+gg·J‘QurÑs}Ñ“VÃìCÁÄ•Ğü–As\`ÔkSÖ0ª…#Š]«–ÃC°átù‰…;}Â#¾ûø:öªÂ¥V]¸ÔÊ×*hösFñ‰ieÿâÊÚ§TkÏ¡˜i*ÙÚYÌôÆ»ÿüb#š‘'	Iã¤JŠ“È¾%0~h’â¤	Š“Æ)N¥8iT“Fõq‹³(Nšù@“%NÊaqÒ¸:NzÎ9•8é'¡mœôü
Ã*ïı`Eú±“ã83RÒ¸6jJlĞ6ôkºµš6Xoß8yİ ¿IŠ¤âÚHª[‰™úyÌÄKT‚ª|fXlk±¸ƒwr1ëœ#©qÃHjÂ<’RnÍ-’7ôe³‡Õt#)4!Iİ´LYáĞüÖ"CÒÀCr$%¤Š¤Æ#©Á”‘Ô`Z‘Ô`ŠHjÜ(’šRERãI‘Û²HŠŒ’="%¤ªéQ¦‹\TI­Éa‘Ô”I)‘ÚEƒ&˜,’ú9}­jJˆ¤øğr$õ}üB–{ÙCüéVçe†ÁÛ«›µFÎd¤g™šxêáÄxJPäDò)xâHâP¼¼Rååû•ïLıZe’¿°˜<N›dgJ“ìLË$;U&©yôH0ÉaÉ$‡“šäğ\Lò‡Ù‰&9œ÷…Ÿ
‰Ñ8‹ èÿ®gÒôœS‡}l÷LYÙj“HN6¨>Üz%‹Â­S[aL²îŸf)Öbï45m“°yÜ4lî6Y}gÚa³™mà2læ˜võŸMtnÅY: ìP9Ö¤_ùi$œnØ<n6Ïw?™©›¥5(kV"hİ¨´œÑ4¾@5›Ïjµa3?ì.`ñqÂQ-…ÌìÏaTO¹ŒÎ»o¥Å@ÉÍS{Š·­TMNPk†söïWõgà#ĞbŸûø«)ö$<Rœúª@'UºØw7œé³‰ÎOÀ‘)Å&[šPÙÒLß‚³Ç‡ÿ[âŸß£‡<)éI„h†O"Gßt:zŒ°¯ŠÙ£‚}š×á	Âçux°°Oa½·Rì±Ÿ¤VŒ¶'z‚íªsôí­éy¶¦gâï·ĞêşI^‚ã4ÕÑØä^ûXÏ“Úİ6vtû„‰uL±öF£óŸßÓËŠC»Úƒ$sİ\w&ïş;ÙÃânXşdş/’aò]ÛàV<AuûAuø—ø—}•"¿Ùó#)2ÎëV®¼!®ÈI¬÷VöØ_¤VTäX/P¨ÈQ}$¥"ÿ•–2BŠÕ+r,©Â˜;éÿ6vÌMaÖÆãÉNªÊ*¾…TÅŸ'T¼V§bÙ:QÅVIÅ’MÆKäæ™æ)Ùänd
UÆ>Ï‘©qB¯Æ¤«›Jª’Fõªæó«WÜş“Õr³Ñ­•-ğUeÕ“½@¥½ÖCI×:iâ/ÓsXæ÷Œ—ùEóe¦<røBåÓçEÉSÒ;r~¨9rI×°“Fz'‰ â´7·ƒ4?fêu>u 
 Ø$€–ÊB®0¬‹\a\©“¼JàuTêÖ{++zìOS+ıMP¨Ôa˜ÕPJ¥^a¡¯I©Ãz[2ûı4éñ3’äø™HºÖX§8‘ÌH³&UÛ.eÙ´ 4üÖ0a_:ûv”%?­L¶$®?ÀÓ<Êdläf*!£¨BÆ|2Z%däú˜ ”´õØÇ”„GŸq¦Ôzº(9L:Ñûşh
«JjP»Ï8<'ÀÑA7wƒ…<GŠ\•‘ìĞ1N©å‚£$,¸O’çˆğ8NIÆ%§ˆœR"f¨2‘Ìq“…uó;¯51È­æ1HÑÿa^R§N#Ì3¦·kR	Ì1Ìûøx&•ŠÍ=ÒUœâ ¶šm	„>•~¨m3ßƒó=à§ôGeäkv@wJÍ10U<ÅÍQwO%;ˆãFqĞ\‡Û“?®ä«1~ác[†÷æÒfœ4bšÒ{2Ã{} jŠ÷‰,ëáÃ´ ïÌ÷˜”tÔœWˆÁİîxÒx}/ÙY*)ì^sÙû‡l.ñ:ø?
s9Ç#ÿ›iù¦'q2ÅIæ'ôSjeu™˜Ê‹§óâé¼x:/Î‹§óöé,h.//ûŞztğ÷Ïo4tâû¹#>·§•Ş¬+%r(¢ş»ßİ*½È?…ÃôÕ„÷ªKïÇ·áJI%yş`¸=¦¼Dœ¥#q`ŞCÒ«¹A&jÄ¢EÂîàÁĞÁ ½H˜‹Ô¯$W$ù£bĞ3õPÏ¿Í8­Fboööc%ƒF»­Í4`ĞÍd<TR±Z:=
0Å"ş|•ôšæFÀ¢òw9§›F…ÑòúÒÛâQµ;Ü;ŠtvÀ¯N©r!/-wï,V‹uåÒœ~ğ‹2h[Ÿ)şz¥*‰!&×z_F¾Æê¼%Y×CLü6òáë¥†8_‰)ßzßığ	s¾m¦|[t|OÃ§‚óg1ãË±hùØOÂœï=ÓñŞÑW]ğ¯_ñºc‰ß%Z¾ téç|¯™òMéøş
ºìá|ŸÊ1ã»8GËwºˆœ¯p™ßË´|fÀqøñ}i¥_×J-_-ğs¾ëL÷a£n_çó˜òíÓñıø*9ß¯M÷ï”nÿ~|9œïS¾Wt|ëáÎÄâ+6ç:İ<½pg€ó7å{JÇ÷U¸³ÿÌÜ×÷"Ü)ä|m¦ãµêÆ[™%Óïß>S¾½:¾jàyîûwø:9ß1S¾{t|?Âÿ_ƒóU›òİ¨ã{ø¬ïÏİß¯Ì„É÷ˆ¯Üt<›n¼Fà|oîã}øZ9_‰éxëuãŸí½¹ë%Nœ™wç>Ïëoôİ¹ë%|İóïàs¾;7½,¿‰½îÚ¶B1”·CiƒòßìÔ>a§övj¹šÚOTSû5ÕÔşğ6jÿú6j¿bµo¥öon¥öSUÔ¨¢vWµÿ¸’Ú¯«¤öÒJjÿÑÔ^u#µ—İHí}[¨}åjÏÜBí]7Pûù7P{öÔ~óõÔşÂuÔşäuÔşìg¨ı³Ÿ¡ö>CíÍ›©ı
jÿ?ÔSAí=›¨ığ&jÿÖFj_½‘Ú/ØHí•S{Q9µ_VNíg7P{Ëj¿}µ·”Ú+J©½¸”Ú+¡ö[J¨İQBíÏÙ¨İc£ö[mÔ~O1µ#í¿-¢öç‹Ø;:6Ñı¿¾Îm(ÿ’—òò‹¼üc^†xy;”0ôµ»¡¼äô\Còr¯¡öe×°wÔ­#Ú±½µàók¨ßùk¨ı<(/úô•Ôş™+¨½ÊOı=~Ğ_áe/;xÙÂË[yyÿeÌœ®¼Œæ™ÏË•¼xù;‘Ê8/.Ò¸/à$á¿½”è—²ø®àbN¯‚òS@ÿSÑCùI ¿ş)šÿô%Ô~úö.Ûï%4¯^nåe	/E^æñÒ›Oó?ó	š×4/_åå$/Çy9ÊËñò/?Aãåì=£».&ºJh*øÉEDA	M_@ó~wµÿJ¸UĞ´Šæs/+yYÌËOóò<^±RYC/„-øUÍç¼|–—Oğr(Æûf‹­åƒ¦TpÃJš¾Ûß_.ç=´œóA	C”.§q/ã¥•—³Ë¸>—q}æp}òòU^ş4‡ä=—ÃŞe[0¸”è¿€¦Vpw6Íã†,j¯€ò< œIò¿ÇË¯ğr)½T· ±Ó5¸ÿP‚éÜ–ÁŞéZğÙ4BÇÛm¼ßP®E¹öŞà‚¿ÅÓ÷ÇÂŞ[ğu{lÁ ”°¤‚,ì]¾øÎm˜jÁ(áØ/ˆqş;-ì}¼MöİŒF`ˆ‚o	ì´÷óÒ#°wÕ^Ç Ÿk¯!¹v„îÃ\+·ƒÓX‚åVrKp™ÜNc	.’;‘M4–àÇ¹œÆ\&w?§±ÿÊ-ä4–èJÓYDc	ş•;Âi,ÁUr;9%Øy®ƒÓX~ÓX‚çNf%Øwî §±ûËmå4–è6Nc	v—;“A4–`w¹£œÆì&·›ÓX‚İä:9%ØKn>§óÉr§,Dc	ö;Äi,Á.rÃœÆÖ
Nc¹M’ÓX^ô˜@4–xÄösËB ÷pK°û\‘ÓX‚İævat¡¼ÇzUn–òŞè'Ğ2•÷RßœEt+§/Ï$z„Ó¨¤Osú§ÙËgáêät!§súNwp:Ìé§8]´”èQN?Éçw±4_¼ºyşZ¢¯Æùe+ï­v.¡ûKxVË"ÚÏ“tpşÛøƒù
ŞK)Ñ_æıÛ6Î$ºŒ'ÃØÀù/§×gÏdıÀ&¢ë9ÿ[ü}İ×p~çgˆ¶äıâu|<>~şDpyçóo,åü7İHôıDWUòıâò"üŠ_rym%º…Ëæ_(Ìry¯Uı/\ŞËv¢ÿû/QŞÛ]Švã]Æõ/-]³œ~Š·}—ÓòûNG8ÿÇ
Ò?æ/:ßÊé³yDáô%üy}šóóå	oK÷	O…ø¾î«5ôg5ôW4ô§5ôƒú2­€×í„ò¦ú:§+
…]ÁP°-ÅBA¿ÇÕÒî÷ú¼® ¾Â>Eö•›º“/Œ¡ƒn‡©­€ñÙĞH±`]±)ğÌR"hS/¸<nW¬5:èjr{],“Ìï +à¶ÄZ,@®†'Âü>œS®…sÏ˜Ø¶>ğÙŸğ)‡OÙ¹Î¬Èj»šƒEeç>G•¬À¶ğ)Ùp-KÛp[(dAµa…J*]•.„Jçï ‰2DÏ¥¨çRÁî %h–ø)Yµ—,„ÚK@í%¦ö’T;*Ú†Ê¶-„²m¡lÛ(Û¶`Ê¶- ²?’D]‹×‡q©ò¿••y±Ğc$ÍÿWbÛTZ¦ÎÿV"ÚJÊKË6,æû(.uŞ,üI¿f›‚g°.ü6B ¼Y…æy®„°1Í?ÒÏ¬©òfí¿”J)oÒ	¹¨ty³¢±ö¦¨©¼0ß«u*Zı•Ãå)óCy®V_ ì3ÊûôU.o«ŠN>¿äy½¦¸¼J-˜_©òz‰ü†”×éäy½’çÍ²rOòf!)˜_h'ø’ËU]µ«JuC²«1©úĞ<‚WôP[S(€ùrMåå¨hõ¼pºê¼V.WK(–@'ÊËÑÈË1—£¢]®€;Ùü¬\^…ŠVËÃ¹-SÑ¨7“[[³ãf{u´’€Dz'@³‰öŒÿ73—rn°lûTFÂîX«şˆ¿$Ú¸\\_N'å	ÛÓIrº¡Ä·dWÜ+0ã‘ò‹ueßû	÷	BkNb~±‹ùó‹‰½i¯™.eiêëS|œÈ÷îßÜğJé-_r¾!Ö|§½¬”ËdkÃ¼gğÁ:ÓmæYË:!QşÙ„ƒËb¶¿š2ù·G#ÅÇ(…cÅ-ê†•›±y=×\S´QBBöoFJ9-ºe<E9	rf³p5$‡@¸ò…oU£0òU&ğÑÎ«ÆO×ãqEU_ÍõRq”ä¬å4îãâµx-^‹×âµx-^‹×âµx-^‹×âµx-^‹×âµx-^‹×âµx-^‹×â5÷‹¿PAì9òf¯ıMÇ€ãqş?<ç96O\AmONeÎgß„oC8ÿıv,í3^ûŒüF«£çÈŒãè‘!v+ñ>öû·ã‹Ì„~Î€áöqö>¬½gÍÆßÖßÎ[U™ƒÏTZå8"ŞÈÇŒP3w0=GÎ=r&#ïØ7@«=pŠj–¼c]Rí|9Ë½GÎà×ïñ@E€JŞıøF‡^û™lü_EÎ,Íûâ_CCÏ¨£ïBä}Ùøÿ½÷feà+.Âß	–‰Ù©¼KÙßYãßL7À§>øót>ú	FÚ= Às>í†Ê°²*Ïb¥*¿ÅÊv¨Ìbå¨|V~º*[°rTvaår¨D±r	Tş+V¨¼ŒÌ¯ó=`¿CÚ€JĞiÜÑÓ>åèÙ=éè©›¨î±×öÔ=’Ÿuğ¦·VVw¾juK¤ÕõãšñÏØñ]øç÷êü@û}ºüÿÒ±ˆ'ÎãÄÕ@<'p²¯š+ø3Ş­êßBşÍö™ö\°Qh_:²ßù]ZÛkí=2îè­›`¯ªìmÇ÷vÄgÛÅÙvkmïî™º'«zĞªfO8>mí—Sí· ø'X¾©GÙ+ñ{b¯ÑïéÃWèW÷t=r–¥*Â÷ä;>1xVJU„5¦Êöj4CLJ4¡¤tœTR:N)©Šâ,UJ”S½¯1ŸHHéøx6¥#š4Héøµlæ£l74YŸ{ÙdÁmš016¾RTj¸…Fä†Jjîí{„R¤Ã’páµ½”}K=hXŸ´ÓAéÏ)ç9“É3|Ræ¤9ÏX+ñ_mU¥2LéƒRóúôy5†•œ¨æ·ò™¼"U÷rm’óÄô@§öáÿk/ešr->—Ér¥L¤ïÓ.KŸ+EšŠy®iRøz÷Ò­f¹R”©ërÇ°\)Ğ›ş1}åJÃü[g•\)Ìú¸)ã•%«èÃNÉs¥dR:â®IqL¾çuL
&ÅÒ÷Ä•ô=(ù´&Kßó§”¾'¾gR“1	N3·èlÜ0ÏÛ(GºoÖfÏÕäNR!N²tOoSş¢U]•³³R.ó
ÅÅlŠ‹aZ\ÉÅäbt@Q¢İ>Vh]¬e¸ØçoLÌÁ¤KA2¢xŒù-ƒ$Y’æ6Ö^ºg	CIdaLÈb$%áÊÛ£(Ï©R^+©Ëi ®¿@uÕoáI*Öœ‘Dïı½$ëx¼î÷ÒVWıO$Íƒ7LàÒAà&pi%pÙOàÒHàâ$pqÊàâ”À%‹.
¸t+àÒ¯€Ë —F5¸Üº¨ÎpÙº„À¥Û \®^b.Rá^6iPÁïH ÃŞ|GŞğïïp‘£†¡Ş¾FrÇ!Xk+¡N‡u¤<|+‡Ô0A<Ñ¥¯¢¬6ãL6ÃWÃÆ¸{¨œ¿dDÊÜM¢yºÉ|nReŠäÈ½æÓ×§‚°F33=F´`
^´xcTn¥a„M„õ§‚°Æ€°Ğuó…°F#« ¬‘ ¬S02±¾pJ»ŠCX·„åd2+6Í$a4(Ï•8`2û‡°i	ÂâªáeûaŠÏØ‡uca†‡ğ°‰íiÓ<AØ´aƒòÑË¾)	ß‡•„ï#Jì8ªÄùrìH®VHÀÖš2v|çJp¼oU$[£!°µš›rË Ø.KlÆ:M×ŸMmd`ÃHÉd‚¤<›Í Øú®Âóo¶Ug0ëœV@.6­ [ë´´™ÇãÓ8HgR›&« ³ÈÈ‰r«	ä¬rVä¬ÈmØ$\¥räœ
Èía ·Zr÷czF–ÃP¹JìØç0 ¹Æ¥æà–*Ñk/[¾.ñ7Öñ†ßüZÂ:ŞğË_s¬“~BƒrÃ©a@nø5ôË_¡†îŞ¾Õäûƒ ¶BÂË
-^Ji”Ÿ‹C<‹7¡°€­ÌÿØH<S4%ƒ•ÓBî7ğ¿uèW•›¤{Eaút¯¢9R)·æ–îuõ9Åæ¦é^+%$üI–²ÂÑù<bšçPN÷ê4 ÛIİˆ:°I	¶#*°Í(3ÛØ¥{]}Ö İ«M¶«	lÉqYºW²Ï>[J°ı9[ÇYƒt¯ØÚ°UiĞ.4qÀd`ÛDÚG°½>ÁVq8ûÎÛ£"cÓ0Ëı§µIM¤£</b¢W{'’<z·’½_‰“ŒÒ=’‡™Éÿ|ø4¾+aÕİºUËs˜VæWF›R–IÕÀ”ÏœRNËÉÚ2âëªâøN.RuĞ^híÊ-hw'‡ös;U’>³òÔğêä‹Ô"‡OıJø4 „OCú¯Ş$Åì°ÿ7¨J|ƒı+ßW ¾'®@ı‘¸õwÅ¥}<÷Å¥YÀóo\š<ÿÆ¥m‡çß8N¤2ih`£<ğ3”~šòÀSfY–yBƒ“”~‚òÀOÈyà'¤<ğùÅRh (¡AX•Ğ Ÿ…'Õyàÿ<GÊV¯„]9†¹ŞYhàÏI?r¾÷²E€JŞz]|Şpòu	ğyÃó¯K€Ï]|Şğİ×9àKÔĞÙÛw’2ôö;(;/xçŒ6Ë{?OïÌM¨BñM›2ßdâyZè®)Ji+’oŠ¾ùE×šÀşIÃ,ïSæYŞ•[sƒı“†éU‡LT›lİö	ö—/1Ip=·µRÃ‰I«ö­©`ÿ¤aJí¡”°?¤‚ıëÍ`(ìŸ4Êò>­J©}’Rj
ì“QöM§L©E¿nH©|aÿ,ûÓJ–÷aöiĞ.4qÀd°ÿ`Áşpìçh`¿åÁæ^Ö‰.¤s1CØ76Î4m2)ìK !CE+©»SŠÑ	ƒ÷(ÎíT97ÏPí4pçÛ/wv­U-¸Ÿ#¾ñ‚MŸ4Müİo²|mÚnóÄßfú5R&şÏ&&ú<›¨ÓE‘ıÊÙÙ­R$ET<':=WÑ=Zµ~ğiPkNabsÒ0ñwÜ<ñ·rË ‚9nQ'ş–Ö4¦¬aT	
G»V-‡‡`Ã¸íâ¦5&‰¿Ïíô5øìãëPçªnÕ…KRnjA³Ÿ3ŠOL+ûWÖ>¥Z{ÅLSkáÚo¾šÇLo¼«ÄF»_Vb£š—•Øè†—•Ø¨äe%6ºêeiFÇã—¼ŒƒIã¤JŠ“È¾%0~ˆÒÌ³Èâ¤qŠ“F)N•ã¤Q)Nš¾JŠ“XœEqÒÌrœ$(qR‹“ÆÕqÒû+¤\ÚJœôÆ
Š“Pˆ6Nz~…a•…÷~°"ıØÉqœ™ ¡ğ8E<ß~IŠšxÃC/IQo8ö’5ñ†èKRÔÄš^âQ“Ôpk`ƒõöÓ‘×ú›¤H*®¤º•˜©ŸÇLÜ°D%¨Ê?«d@§X‹Å­¼“‹YÌl3¯^aIFRæ‘”rkn‘Ô¹%ª7¤x:ö¼¾›–)+šÿÀÚCdHxH¤„T‘Ô¸a$5˜2’TERO^nI¦ˆ¤Æ"©)U$5N‘¹-‹¤È(Ù#RòHªšeºÈE5‘ÔšIM)‘ÔIÑ ]4hâ€É"©ŸÓ×ªö¡„HŠ/GRßÇ/d¹—=ÔÁŸnu^fL±½ºYkäLFz–©‰§NŒ§´± EN$Ÿ‚'$ÅË+U^¾_ùŞIë×ßúøõJ‘ı€&™ä/,&Æ&Ù™Ò$;U&Y$š™d§Ê$5	&9,™äpR“‹Iş0;Ñ$‡ó¾ğS!1 gQãôQ#;S‡}l÷LYó’ª$'Tn½’EáÖ©­0&Y÷O³ëF±wšš¶IØ<n6w›¬¾3í°ÙL‚6ğN6ó L»úÏ&ºN·â,
Pv¨œ…kÒ¯ü46p|ß{üg«õV¢›ç»ŸÌT‡ÍÒšF”5+´îTZÎ¨ù¨“¸ ëj“°ùÜ V6óÃÁ>qàãQpÅj~dK!3ûsÕS.£óî[i1Pr³ÁÔ¤ls+UÓR²¦Ñ¿_ÕŸMü@7Š}îã{¬~¤Ø“ğHqê«Té2`ß=Üp¦Ï&:G<G¦˜TliBeK3æß‚ß—¶ôô%ü1äáÿV=^8¡<z<uByôxì„òèñğ	åÑãk'T“:àÏ4Ã'UV@|3iN@–ğ¤CÎ8ÑTêœ€¯äS.¼'hOÍóN›ä¼3KZ,±z²êèA¿Ê'z[aúNö°˜RğRš|×6¸_™ÿ±&RÿóOœc"õ„“ÆLI©ë&Mn˜ÄÛ ‘ú/V%RÿîÅf9+­’Š%›Œ+–ÈÍ3ÌS²É	ÜHSUî¸XÎS9Fjœ0ÏS™$)º™Jôy*a> bZñsñ<•ÿp‘‰/ZU¾(¯•-ğUeÕ“½@¥^k-v(éZÍòMš%¾5Zæ÷4ËüÙ2¿ñÂù9óLCº<å‡š#G—ï×Ì°“Fz'‰ â´Yšßƒúcfäòzôo] RWÔ5€(€>`“| Z*¹Âxå)^ÏçàJàuTêÖ{++zìOS«Àş¦(Tê0ÌjÈT©Ÿ¤9»ÂB_’R‡õ¶döûiÒãg$Éñ31ŸüÂIĞÁì€4hRµíòQ–MÛJÃoÙ6ş×*ÚÆ— çã¿\õ‘eGW¥q”%?­L¶$®?ÀuGÙ¬•eÓV“üŞ…ªüŞ¢
óUÈhUÒí2}ğ|»¶û¸‚’£RêİÔº©>¢Ö”&Œè}4…U%5(m>ïIU>ïd‡€qÊ(8GIX(şpÏıgy*”<š·0È<³[i.ÇN¤
DÌPe"™ã&ëæw^kb[õ1HE.i·µ{UîÇæıÍyçæ%uê4Â¼sNÌmæıb¥Ê€ŸZù±p=ÍåØL*›=z¤«8ÅAlš\Î
Ÿ~¨mÓïÁ-+hğW±ø–&'¶¨:±?,#ÿÉrÚÇ5; ;¥Çæ˜‚*âæ¨;ˆ§’Äq£ƒ8¨×áy4ó®í¨Ã÷–™a|¾ã2¶}p™Œ÷æÒfœ4bšÒ{2Ã{u š·Œã½°,µËzø0,¨7‡,è;ó=&%5çbp·;4^EßKv–J
»Wc.¿\Jæ²Íåù¥¹¹x—¦a.ñ:øuæ‚o\gæò³%e.ó<ò—¹|3Í#ßô$N¦£8éÃü„~J­¬.©`º84•;ĞT³?ÆÓ¹8ûêéÊRÎY¹»½“ùqÎwerwÃ?|ÿXOç·2şGœÎ•ªÓùÚŒÜ\±|œ§óV7—–ùtşGáşt¾HPÎ˜½àÙ½ê+Í^õUöï×Ø¿ƒìßo°ÿŠıûm–"£¶¯à¨T5Ì^…eë}¾$„µâíS'±¶k'°¶kcX»kÿÈşh
ßƒWß[şş™aÕT¡µíüê”*»Z}¢?æ‹¸cşPPŒøÜVŸWô„‚|‘_Ğã+RúAëçÚ[Ü1ŸØq{ı¾`LlóÅZC^1…ÃÀ×tHŒAÇp$ÔñE£¢ï€;ĞN¢›Ûƒ¬¨äùƒáö˜xÀñ»›¾¨èøDw æà=$†Â1›ÿn	‚Ú±h‘°;xg0t0(²„›EªùG¡ŸjVIòGÅ fê? ›»Ãßæ¨Öch{cG_8êÀm½vf„ÉC“u3zr«å…#>P­×Ïº´¹c‡èq×ÄÄ&ŸlÄæPDt'ô£M2ŞZD[Èëˆ¸\µ;Ü;Š0g3»,wï,V‹uåÒœ~Ë]ù¤Ûcôú&9åK:e®õ¾Œ,LErŞ’¬ë¡ &~ù0¥ËfÎWbÊ·^Ç‡¹´K9ß6S¾-:¾§ásç;ÏbÆ—cÑòáOÎçÿñ½g:Ş;ºñÊ Ë‹œï%f|{–hùĞåİ'ˆï5S¾)ß_A—o?M|ŸÊ1ã»8GËwºôŒ_á23¾+–iù.„£ëĞ/ˆïK+ÍøºVjùjïù_ßu¦û°Q·˜Óú…WˆÏcÊ·OÇ‡9ßıâûµéşÒíßï€ï¯ß¦|¯èøÖÃ}¯_±é<×éæé…;»_'¾ã¦|Oéø¾
w^}cîë{î|%N|m¦ãµêÆ[	±ğOOß>S¾½:¾jà{ç?ç¾‡O|“ø™òİ£ãûğŞ"¾jS¾u|o_Ç¯çîïWÂ£Îg~C|å¦ãÙtã5ß¦é¹÷eà{—ó•˜·^7Ş8şİÍ]/Ypâœ}{îó¼øF;w½Ä€ï‰ßÍ}¼G€ïwæ¦—T×c</İ(/Ÿãå‹&¹I–qñZ¼¯ÅkñZ¼¯ÅkñZ¼¯ÅkñZ¼¯?ˆkÕeÖ][o²Òåºİëvn¹Ë683Ë/K?¶İm‚ºí‚Jï¡€×µ7¹šüA¯/"t)·Qî\Äaÿ»¬çWºnª¯sº¡PØåz]ÁĞA·?&ôwå'Ü†‚m¡`(
ú=®–v¿×}}¬§˜²'ûi»J]Ãîˆ;ğ°±õàòt¸]±ÖHè «Éíu¹#÷!á +à¶ÄZ6a,DX*,)~d©xZ\ÍŸÏé¦2JK‘ôúšİí“Şæ‹ù"ÑÂkà–sûççÍ^§×own÷7¸J\^çÍLööûí¥ØèoØäbw…ße”„w36šüXAÓ<d¼“)dØÂO,8û‘”ñÿ™!d@‹ğ`†$½tâßñm ÇÇ/ü{F48à‹ÌQŒåü&#S˜Ú"d
_¿ş9ÿ<T	ÿ|c+üóÕjAÈÏK…§3amóà›ÎÌŞuÂØ¿Üÿ¼²„¯ßk)V•lëËxÏòÒÊ×ÎûëĞù_ºä2ş#ã×–7,?È8ùkË[¿úXæÓĞçQøü0Cª1¿ëÈ„\¨^SG~øcN7ïà™Iô³õDVsúïœD÷púk·ı§²“è²ˆşò.¢÷pú»‰ş_œşÍ­D¿Âéº=D¯É&zx/ÑN—ıÑqº£‘Ïw	Ñ‘;ˆü,§¿³è/súë.¢Ééû‰^·”è‹yŞûœ¶zˆ~ŠÓvşƒnnÑ7úˆ¾iXÃÿ>mÎÃñ*¹ş8½ÿR¢wsúòËˆàôE"Ñpúïÿ,§W_Î·ÇBô¾b¢·púP!Ñ‡8ıuÎß-İßDôÔ-4MÒ‡†ÎÈH¤×hèŒî”¾õ¶hh;õ—é¢3%—‰KÇå\Ÿ+ás|®¦Û•kRô8ÿJls92HÜ—Î¹aşÇŠĞpĞf~&ÃÍyÊÀY˜ß¡ÂXçw«n€<'T0ÆÜtĞ6-œÕ ¬ğ  5ÔêâŒyoW‘+Ôv5‹l £dd”ƒ$.æ\…”,„YÎ†sp*­NÎMHÉB)]!ÎÕÇ³ ’JLRé‚IZ8=•;¶%ê|d•, ¬Ò”µae1İ×V R3¯÷
ø›Šá;SXëoú0Æ°Ùl›ÊËEVn¤ÒVZF%¿Ä’7•”••—o(m%›ÊKJ±”O¬¤¨üÃ›\;*0•»[İÁ–C~Ó~Ğ­9Ùß:ğuÈåâµx-^‹×øõÍ”Ë $ 