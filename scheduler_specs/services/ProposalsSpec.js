describe('Proposals', function(){
  beforeEach(module('schedulerApp'));

  beforeEach(module(function($provide){
    $provide.value('Config', {conference_year: '2015'});
  }));

  var Proposals, $httpBackend;
  beforeEach(inject(function(_Proposals_, $injector){
    Proposals = _Proposals_;
    $httpBackend = $injector.get('$httpBackend');
    $httpBackend.whenGET('/api/v1/conferences/2015/proposals/search')
    .respond(200, "[]");
  }));

  it('should fetch the 2015 proposals', function(){
    var proposals = Proposals.fetch()
    $httpBackend.flush();
    $httpBackend.verifyNoOutstandingExpectation();
    $httpBackend.verifyNoOutstandingRequest();
  });
});