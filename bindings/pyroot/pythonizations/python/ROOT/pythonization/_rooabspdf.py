# Author: Hinnerk C. Schmidt 02/2021

################################################################################
# Copyright (C) 1995-2020, Rene Brun and Fons Rademakers.                      #
# All rights reserved.                                                         #
#                                                                              #
# For the licensing terms see $ROOTSYS/LICENSE.                                #
# For the list of contributors see $ROOTSYS/README/CREDITS.                    #
################################################################################

import cppyy

from ROOT import pythonization


def __cast(s):
    # NB: not implemented, returns input
    # If needed this function can cast the keywords
    # I.e. one could pass `range=...` instead of `Range=...`
    # Parameters:
    # s: string
    return s


def __getter(k, v):
    # helper function to get CmdArg attribute from `RooFit` 
    # Parameters:
    # k: key of the kwarg
    # v: value of the kwarg
    k = __cast(k)
    if isinstance(v, (tuple, list)):
        attr = getattr(cppyy.gbl.RooFit, k)(*v)
    elif isinstance(v, (dict, )):
        attr = getattr(cppyy.gbl.RooFit, k)(**v)
    else:
        attr = getattr(cppyy.gbl.RooFit, k)(v)
    return attr


def _fitTo(self, *args, **kwargs):
    # Redefinition of `RooAbsPdf.fitTo` for keyword arguments.
    # the keywords must correspond to the CmdArg of the `fitTo` function.
    # Unless `__cast(s)` is implemented such that the translation is made.
    # Parameters:
    # self: instance of `RooAbsPdf` class
    # *args: arguments passed to `fitTo`
    # **kwargs: keyword arguments passed to `fitTo`
    if not kwargs:
        return self._OriginalFitTo(*args)
    else:
        sargs = [__getter(k, v) for k, v in kwargs.items()]
        return self._OriginalFitTo(*args, *sargs)


@pythonization()
def pythonize_rooabspdf(klass, name):
    # Parameters:
    # klass: class to be pythonized
    # name: string containing the name of the class

    if name == 'RooAbsPdf':
        # Add pythonization of `fitTo` function
        klass._OriginalFitTo = klass.fitTo
        klass.fitTo = _fitTo

    return True