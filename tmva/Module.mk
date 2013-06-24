# Module.mk for tmva module
# Copyright (c) 2006 Rene Brun and Fons Rademakers
#
# Author: Fons Rademakers, 20/6/2009

MODNAME      := tmva
MODDIR       := $(ROOT_SRCDIR)/$(MODNAME)
MODDIRS      := $(MODDIR)/src
MODDIRI      := $(MODDIR)/inc

TMVADIR      := $(MODDIR)
TMVADIRS     := $(TMVADIR)/src
TMVADIRI     := $(TMVADIR)/inc

##### libTMVA #####
TMVAL0       := $(MODDIRI)/LinkDef.h
TMVALS       := $(MODDIRI)/LinkDef1.h $(MODDIRI)/LinkDef2.h $(MODDIRI)/LinkDef3.h $(MODDIRI)/LinkDef4.h
TMVADS       := $(call stripsrc,$(MODDIRS)/G__TMVA.cxx)
TMVADO       := $(TMVADS:.cxx=.o)
TMVADH       := $(TMVADS:.cxx=.h)

TMVAH1       := Configurable.h Event.h Factory.h MethodBase.h MethodCompositeBase.h \
		MethodANNBase.h MethodTMlpANN.h MethodRuleFit.h MethodCuts.h MethodFisher.h \
		MethodKNN.h MethodCFMlpANN.h MethodCFMlpANN_Utils.h MethodLikelihood.h \
		MethodHMatrix.h MethodPDERS.h MethodBDT.h MethodDT.h MethodSVM.h MethodBayesClassifier.h \
		MethodFDA.h MethodMLP.h MethodCommittee.h MethodBoost.h \
		MethodPDEFoam.h MethodLD.h MethodCategory.h
TMVAH2       := TSpline2.h TSpline1.h PDF.h BinaryTree.h BinarySearchTreeNode.h BinarySearchTree.h \
		Timer.h RootFinder.h CrossEntropy.h DecisionTree.h DecisionTreeNode.h MisClassificationError.h \
		Node.h SdivSqrtSplusB.h SeparationBase.h RegressionVariance.h Tools.h Reader.h \
		GeneticAlgorithm.h GeneticGenes.h GeneticPopulation.h GeneticRange.h GiniIndex.h \
		GiniIndexWithLaplace.h SimulatedAnnealing.h
TMVAH3       := Config.h KDEKernel.h Interval.h LogInterval.h FitterBase.h MCFitter.h GeneticFitter.h \
		SimulatedAnnealingFitter.h MinuitFitter.h MinuitWrapper.h IFitterTarget.h  \
		PDEFoam.h PDEFoamDecisionTree.h PDEFoamDensityBase.h PDEFoamDiscriminantDensity.h \
		PDEFoamEventDensity.h PDEFoamTargetDensity.h PDEFoamDecisionTreeDensity.h PDEFoamMultiTarget.h \
		PDEFoamVect.h PDEFoamCell.h PDEFoamDiscriminant.h PDEFoamEvent.h PDEFoamTarget.h \
		PDEFoamKernelBase.h PDEFoamKernelTrivial.h PDEFoamKernelLinN.h PDEFoamKernelGauss.h \
		BDTEventWrapper.h CCTreeWrapper.h \
		CCPruner.h CostComplexityPruneTool.h SVEvent.h OptimizeConfigParameters.h
TMVAH4       := TNeuron.h TSynapse.h TActivationChooser.h TActivation.h TActivationSigmoid.h TActivationIdentity.h \
		TActivationTanh.h TActivationRadial.h TNeuronInputChooser.h TNeuronInput.h TNeuronInputSum.h \
		TNeuronInputSqSum.h TNeuronInputAbs.h Types.h Ranking.h RuleFit.h RuleFitAPI.h IMethod.h MsgLogger.h \
		VariableTransformBase.h VariableIdentityTransform.h VariableDecorrTransform.h VariablePCATransform.h \
		VariableGaussTransform.h VariableNormalizeTransform.h VariableRearrangeTransform.h
#TMVAH1C      := $(patsubst %,include/TMVA/%,$(TMVAH1))
#TMVAH2C      := $(patsubst %,include/TMVA/%,$(TMVAH2))
#TMVAH3C      := $(patsubst %,include/TMVA/%,$(TMVAH3))
#TMVAH4C      := $(patsubst %,include/TMVA/%,$(TMVAH4))
TMVAH1       := $(patsubst %,$(MODDIRI)/TMVA/%,$(TMVAH1))
TMVAH2       := $(patsubst %,$(MODDIRI)/TMVA/%,$(TMVAH2))
TMVAH3       := $(patsubst %,$(MODDIRI)/TMVA/%,$(TMVAH3))
TMVAH4       := $(patsubst %,$(MODDIRI)/TMVA/%,$(TMVAH4))
TMVAH        := $(filter-out $(MODDIRI)/LinkDef%,$(wildcard $(MODDIRI)/TMVA/*.h))
TMVAS        := $(filter-out $(MODDIRS)/G__%,$(wildcard $(MODDIRS)/*.cxx))
TMVAO        := $(call stripsrc,$(TMVAS:.cxx=.o))

TMVADEP      := $(TMVAO:.o=.d) $(TMVADO:.o=.d)

TMVALIB      := $(LPATH)/libTMVA.$(SOEXT)
TMVAMAP      := $(TMVALIB:.$(SOEXT)=.rootmap)

# used in the main Makefile
ALLHDRS      += $(patsubst $(MODDIRI)/TMVA/%.h,include/TMVA/%.h,$(TMVAH))
ALLLIBS      += $(TMVALIB)
ALLMAPS      += $(TMVAMAP)

# include all dependency files
INCLUDEFILES += $(TMVADEP)

##### local rules #####
.PHONY:         all-$(MODNAME) clean-$(MODNAME) distclean-$(MODNAME)

include/TMVA/%.h: $(TMVADIRI)/TMVA/%.h
		@(if [ ! -d "include/TMVA" ]; then     \
		   mkdir -p include/TMVA;              \
		fi)
		cp $< $@

$(TMVALIB):     $(TMVAO) $(TMVADO) $(ORDER_) $(MAINLIBS) $(TMVALIBDEP)
		@$(MAKELIB) $(PLATFORM) $(LD) "$(LDFLAGS)" \
		   "$(SOFLAGS)" libTMVA.$(SOEXT) $@ "$(TMVAO) $(TMVADO)" \
		   "$(TMVALIBEXTRA)"

$(TMVADS):      $(TMVAH) $(TMVAL0) $(TMVALS) $(ROOTCINTTMPDEP)
		$(MAKEDIR)
		@echo "Generating dictionary $@..."
		$(ROOTCINTTMP) -f $@ $(call dictModule,TMVALIB) -c $(TMVAH) $(TMVAL0)

$(TMVAMAP):     $(RLIBMAP) $(MAKEFILEDEP) $(TMVALS) $(TMVAL0)
		$(RLIBMAP) -o $@ -l $(TMVALIB) \
		   -d $(TMVALIBDEPM) -c $(TMVALS)

all-$(MODNAME): $(TMVALIB) $(TMVAMAP)

clean-$(MODNAME):
		@rm -f $(TMVADIRS)/*.o

clean::         clean-tmva

distclean-$(MODNAME): clean-$(MODNAME)
		@rm -f $(TMVADEP) $(TMVADS) $(TMVADH) $(TMVALIB) $(TMVAMAP)
		@rm -rf include/TMVA

distclean::     distclean-$(MODNAME)
